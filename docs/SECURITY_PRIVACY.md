# Security and Child-Privacy Release Gates

Battlepets is intended to support children under 13. Production child accounts, online identifiers, free-text chat, payments, and voice must remain disabled until qualified privacy review and a valid verifiable-parental-consent process approve them.

## Required product controls

- An adult owns the email/password account and creates child profiles.
- Child profiles use unique moderated usernames and approved preset avatars.
- Email verification is required before online access.
- Free-text chat is off by default for children and requires separate verified-parent opt-in.
- Parents can inspect, export, delete, and revoke consent for child data.
- Collection is minimized and each data category has a documented retention/deletion period.
- Mute, block, report, rate limits, filtering, and moderation audit tools protect lobby chat.
- Child screens cannot initiate real-money purchases.
- Payments and voice have independent feature flags and release reviews.

Development consent and payment adapters must be clearly marked as non-production and must fail closed outside development.

## Primary guidance

- FTC, Children's Online Privacy Protection Rule: A Six-Step Compliance Plan: https://www.ftc.gov/business-guidance/resources/childrens-online-privacy-protection-rule-six-step-compliance-plan-your-business
- FTC, Complying with COPPA FAQ: https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions
- FTC, 2025 COPPA Rule amendments: https://www.ftc.gov/news-events/news/press-releases/2025/01/ftc-finalizes-changes-childrens-privacy-rule-limiting-companies-ability-monetize-kids-data
- FTC, Genshin Impact randomized-purchase settlement: https://www.ftc.gov/news-events/news/press-releases/2025/01/genshin-impact-game-developer-will-be-banned-selling-lootboxes-teens-under-16-without-parental

These references guide engineering release gates but do not replace qualified legal review.
