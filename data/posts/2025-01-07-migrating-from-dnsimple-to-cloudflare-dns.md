---
title: "Migrating from DNSimple to Cloudflare DNS"
---

I migrated ten domains from [DNSimple](https://dnsimple.com/) to
[Cloudflare.](https://www.cloudflare.com/) Experimenting with [Cloudflare
Tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) was my primary motivation, but also to learn. None of my DNS configuration was previously managed and I
wanted to bring it into [Terraform.](https://www.terraform.io/) As a cheeky
bonus I also saved $A8.50/month, since my usage fits within the Cloudflare free
tier.

This post is a sketch of the process, with links out to relevant code and
configuration. It assumes working knowledge of Terraform, Ruby and basic DNS concepts.

As of January 2025, differences I noted between the two services:

* DNSimple supports a [custom `ALIAS` record
  type](https://support.dnsimple.com/articles/alias-record/) to enable
  redirection of queries
  to the apex (i.e. `xaviershay.com`).
  Cloudflare achieves this by transparently converting `CNAME` records
  pointing at the apex, which they call ["CNAME
  flattening."](https://developers.cloudflare.com/dns/cname-flattening/)
  DNSimple also creates a `TXT` record describing the `ALIAS`
  for debugging purposes only, so I excluded them from migration.
* DNSimple supports a custom `SPF` record type for email security, which creates
  appropriate `TXT` records for you. Those created `TXT` records were also
  returned by the API, so the `SPF` records could be safely excluded.
* Any record with a blank name in DNSimple needs to be `@` for Cloudflare.
* The DNSimple API returns `NS` and `SOA` records, which Cloudflare needs to
  manage, so these too were excluded.

My goal was to generate Terraform configuration from my existing DNSimple
configuration, something eventually looking like:

    provider "cloudflare" {
      api_token = var.cloudflare_api_token
    }

    module "zone_xaviershay_com" {
      source = "cloudposse/zone/cloudflare"
      version = "1.0.1"

      zone = "xaviershay.com"
      account_id = var.cloudflare_account_id
    
      records = [
          {
          name           = "@"
          type           = "CNAME"
          ttl            = 3600
          value          = "d35moas0x4pv9r.cloudfront.net"
          proxied        = false
          }
          # ... etc
      ]
    }

[Claude.ai](https://claude.ai/) helped me generate a series of Ruby scripts.

1. [Scrape the DNSimple
  API](https://github.com/xaviershay/server-config/blob/main/terraform/bin/dnsimple-to-json)
  and generate a JSON description of my configuration:

        {
          "provider": "dnsimple",
          "exported_at": "2025-01-06T16:58:48+11:00",
          "zones": [
            {
              "name": "xaviershay.com",
              "records": [
                {
                  "name": "",
                  "type": "ALIAS",
                  "ttl": 3600,
                  "content": "d35moas0x4pv9r.cloudfront.net",
                  "priority": null,
                  "regions": [
                    "global"
                  ],
                  "metadata": {
                    "created_at": "2014-01-10T23:23:10Z",
                    "updated_at": "2016-12-28T04:47:33Z"
                  }
                }
              ]
            }
            # ... etc
          ]
        }

2. [Transform DNSimple specific records](https://github.com/xaviershay/server-config/blob/main/terraform/bin/dnsimple-to-json) (e.g. `ALIAS`) to equivalent Cloudflare
  records, and to filter out unwanted records:

        {
          "name": "@",
          "type": "CNAME",
          "ttl": 3600,
          "content": "d35moas0x4pv9r.cloudfront.net",
          "priority": null,
          "regions": [
            "global"
          ],
          "metadata": {
            "created_at": "2014-01-10T23:23:10Z",
            "updated_at": "2016-12-28T04:47:33Z"
          }
        }

3. [Generate terraform config](https://github.com/xaviershay/server-config/blob/main/terraform/bin/json-to-cloudflare-terraform) from the transformed JSON, using
  `cloudposse/zone/cloudflare` module (per above, [full generated HCL here](https://github.com/xaviershay/server-config/blob/main/terraform/dns.tf)).

Multiple scripts made it easier to debug and work with AI.

From there, Terraform was able to create the necessary configuration on
Cloudflare. At this point, both DNSimple and Cloudflare are able to serve DNS
for my domains, but DNSimple is still primary.

Before switching, I generated [another Ruby script](https://github.com/xaviershay/server-config/blob/main/terraform/bin/generate-dns-spec)
to resolve all records using
regular DNS (i.e not via the DNSimple API) and create some spec files that could
be pointed at a configurable name server.

    require 'resolv'
    
    RSpec.describe 'DNS Configuration for xaviershay.com' do
      let(:dns) do
        config = {}
        config[:nameserver] = ENV.fetch('NAMESERVER')
        Resolv::DNS.new(config)
      end
    
      describe 'MX records' do
        let(:records) { dns.getresources('xaviershay.com', Resolv::DNS::Resource::IN::MX) }
      
        it 'has the correct number of records' do
          expect(records.length).to eq(2)
        end
      
      it 'includes MX record with preference 10 and exchange in1-smtp.messagingengine.com' do
        matching_record = records.find do |r|
          r.preference == 10 && r.exchange.to_s == 'in1-smtp.messagingengine.com'
        end
        expect(matching_record).not_to be_nil
      end
      # ...
    end

This was able to verify most of the
configuration at Cloudflare. I had to exclude the apex domains from the script
since they resolve non-deterministically due to how `ALIAS`/`CNAME` flattening is implemented. I
could have written a further spec to check the _content_ at each domain, which
should be unchanged, but I checked this manually instead.

I then manually went through all six of my registrars(!) to update nameservers,
leaving the most important domains until the earlier ones had baked.

All up it took about half a day.