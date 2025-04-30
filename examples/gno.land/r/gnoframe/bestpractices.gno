package gnoframe

var bestpractices = `
# 📤 Best Practices for Building a Sharing Feature on Gno.land

## General Best Practices
### Trust and Transparency First
- Ensure users clearly understand what will be shared, where it will be stored, and how it can be accessed.
- Prefer linking to open content rather than hiding content behind server-side logic.

### Link, Don’t Lock
- Use Gno's realm paths (e.g., /r/realm/) and content-addressed links (ipfs://, ipns://) when possible, to promote durable sharing over time.

### Minimal, Human-Readable Metadata
- Add structured metadata to your realms or pages in simple ways — ideally using something like # Title, # Description, and an optional # Preview Image.

---

## Recommendations for Gno Websites/Realms
### Implement a Gno "Crawler" View
- Expose a simple, lightweight machine-readable version (.gno or .json endpoint) for crawlers and clients to fetch preview metadata: title, description, and preview image.

### Enable Compression
- If you run a public Gno web gateway (e.g., your own gnoserve fork), enable GZIP or deflate for all content responses to improve bandwidth usage and crawler compatibility.

### Use Open Web Metadata
- Even though Gno doesn’t use centralized Facebook-style scrapers, you should still define preview metadata.

### Test Your Share Previews
- Build a simple Sharing Debugger that renders a link preview from metadata so you can verify it looks correct before posting.

---

## Recommendations for Images
### Use Proper Image Sizes
- Minimum: 600px width for acceptable preview display.
- Recommended: 1080px width for high-res devices.
- Use a 1:1 ratio (square) for most consistency across decentralized platforms.
- Prefer lightweight image formats: SVG or compressed PNG.

### Declare Image Dimensions
- If you can embed in metadata.

### Pre-cache if Possible
- On your own gateway, you can "pre-fetch" or cache preview assets when the content is published rather than waiting for first crawler hit.

---

## Recommendations for Mobile
### Use URL Fragments and App Links
- Structure your links to deep-link users into realms or sections inside mobile apps, like:
  https://yourgateway/r/realm/#section

### Support Private and Public Sharing
- Build lightweight sharing dialogs where users can choose between:
  - Public posting to a realm
  - Private sending of a direct share link to a specific user

### Track Mobile Referrals Respectfully
- Without invasive tracking:
  - Use standard Referer headers to check traffic sources.
  - Never collect private browsing data — just observe basic stats.

### Mobile User-Agent Awareness
- Some helpful signals if you want to detect mobile:
  - Android: User-Agent contains FB_IAB/FB4A or GnoMobile
  - iOS: User-Agent contains FBAN/FBIOS or GnoiOS

---

## Bonus for Gno: Social Graphs
### Optional: Add Follow Features
- If building a Gno social app:
  - Allow users to "follow" a realm's updates.
  - Let users post content that is public for followers or private for friends.
  - Add followers.gno or subscriptions.gno files to manage follower lists openly.

---

## 📑 Summary Checklist
| **Step**               | **Recommendation**                     |
|-------------------------|-----------------------------------------|
| **Metadata**            | Title, Description, Image              |
| **Image Size**          | Min 600px, Best 1080px                 |
| **Compression**         | Enable GZIP/deflate                   |
| **Mobile Awareness**    | Respect headers & user-agents          |
| **Private/Public Sharing** | Lightweight dialogs                 |
| **Test Sharing**        | Build a Debugger                       |
| **Support Deep Links**  | /#section anchors                      |
| **(Optional) Follow Graphs** | Maintain realm-based subscriptions |
`
