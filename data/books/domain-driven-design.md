---
id: OL17094759M
slug: domain-driven-design
title: Domain-driven design
author: Eric Evans
rating: 4
pages: 560
reads:
- finished_at: '2011-09-11'
---
Long (I'm starting to feel that way about all programming books...), but worthwhile. Key takeaways for me:
- If business people use terms that don't appear in your model, that's bad.
- "Make implicit concepts explicit." Important business rules should not be hidden away in conditionals inside an unrelated object.
- Constrain relationships as much as possible. For instance a has_many should only be bidirectional if it is really necessary. A way around it is to use repositories to access the information.
- Responsibility layers can be a good way to structure the model (operations, decision support, policy, potential, etc...)
- "Refactor towards greater insight."
- "Distill the core." Ruthlessly extract generic concepts that aren't essential to the domain.
