# Liken — Play Store / App Store listing copy

Pre-written copy you can paste into Google Play Console and App Store Connect
when you're ready to submit. Edit to taste, but it's all here so you don't
have to write it from scratch under deadline pressure.

---

## App name (30 char limit)

> Liken

(The Play Store also asks for a "short name" — same.)

## Short description / subtitle (80 char limit)

> A quiet companion for becoming more like the Savior.

## Full description (4000 char limit on Play, 4000 on App Store)

> Liken is a quiet companion for becoming more like the Savior — built around
> the **Christlike Attribute Activity** from chapter 6 of *Preach My Gospel:
> A Guide to Sharing the Gospel of Jesus Christ* (2023).
>
> You take a gentle, prayerful self-assessment, rating each statement under
> ten attributes — Faith, Hope, Charity & Love, Virtue, Integrity, Knowledge,
> Patience, Humility, Diligence, and Obedience — on the *Never → Always*
> scale. Liken remembers your reflections forever and shows you, quietly, how
> your soul is being shaped over time.
>
> **What's inside**
>
> • Every statement reproduced verbatim from *Preach My Gospel*, chapter 6
> • A radar chart of your most recent reflection — overlaid with a previous
>   one so you can see what's shifted
> • A line chart for each attribute over time
> • Drafts that auto-save: leave mid-reflection and the home screen invites
>   you back exactly where you stopped
> • Scripture chips on every statement — tap to open the verse on
>   churchofjesuschrist.org
> • A "focus attribute" you can sit with between reflections
> • Optional gentle weekly or monthly nudge to come back
> • Cloud sync (Firebase) keeps your reflections in step across devices,
>   tied to your account; works fully offline and reconciles when online
> • Anonymous-first: try it without an account; upgrade later without
>   losing any of your reflections
>
> **What it isn't**
>
> Liken is not a scoreboard. There are no streaks, no badges, no
> headlining numbers. The point isn't to "beat" yesterday's score — the
> point is to notice, to be honest, and to keep coming back. The deficits
> are an invitation, not a verdict.
>
> *The Christlike Attribute Activity statements are © Intellectual Reserve,
> Inc. Reproduced for personal devotional reflection.*

## Category

- **Play Store:** Lifestyle (primary) — Books & Reference (secondary)
- **App Store:** Lifestyle — secondary: Reference

## Content rating

- **Everyone / 4+** (no violence, no user-generated public content, no ads,
  no in-app purchases)

## Privacy policy URL

You'll need a hosted privacy policy. The text is in `PRIVACY.md` (TODO —
I left this for you because the email/contact info needs to be yours).
Suggested host: a static page at https://liken.app/privacy or a GitHub
Pages site. Both stores REQUIRE a public URL.

## Data safety / App Privacy declaration

**Data Liken collects** (be honest with the stores about this):

| Type | Why | Linked to user | Tracking? |
|---|---|---|---|
| Email address (only if you create an account) | sign-in | Yes | No |
| Display name (optional) | greeting | Yes | No |
| Reflection ratings + optional notes | the whole point of the app | Yes | No |
| Anonymous user id | so anonymous users have a stable identity | Yes | No |

**Data NOT collected:** location, contacts, financial info, photos,
device identifiers for advertising, browsing history, crash diagnostics
sent to third parties.

**Data destination:** Google Firebase (Cloud Firestore + Firebase Auth),
in the same Google account that owns the Firebase project. Users can
delete their data at any time from Settings → "Wipe everything for
testing" (still labeled as such — rename before launch, see below).

## Screenshots required

- **Play Store**: at least 2; up to 8 phone screenshots (16:9 to 9:19.5,
  min 320px on each side).
- **App Store**: 6.7" iPhone (1290×2796 or similar), 5.5" iPhone, 12.9"
  iPad. iOS templates are picky.

I'd suggest these 5–6 screens, captured at the highest resolution
device you have:
1. Auth screen (sign-in default, with the rosette mark)
2. Home screen with a recent reflection radar chart + focus card
3. Mid-reflection — questionnaire screen with one attribute and the
   1–5 selector visible
4. Results screen — the radar chart with a previous reflection ghosted
   underneath
5. Attribute detail — line chart of one attribute over time + the
   statements
6. Settings — quiet copy, focus + reminder cadence visible

## Feature graphic (Play Store, 1024×500)

Suggested composition: deep-midnight background, the rosette mark on the
left, the words **Liken** and *a quiet companion for becoming* on the
right in Fraunces / Inter. I haven't built a generator for this — see
TODO at the end of this doc.

## What's new (release notes, 500 char limit)

> First release. Take a quiet self-reflection across the ten Christlike
> attributes. Your reflections sync across devices and stay yours.

## Support email / website

- **Email:** TBD — you'll want a real address at a domain you control.
  Both stores require it.
- **Website:** liken.app (or wherever — both stores require a URL).

## Pricing & monetization

Free, no ads, no in-app purchases, no subscriptions. (Edit later if you
change direction.)

## Countries / availability

Suggest: all countries / all languages (it's English-only for now, but
both stores accept that).

---

## Things still to do before you can submit

These need decisions only you can make:

1. **Privacy policy URL** — the stores will reject the listing without
   one. Two-page draft in PRIVACY.md (TODO: I should write a draft of
   this — see below).
2. **Feature graphic** for Play (1024×500). Generate or commission.
3. **Screenshots** at correct resolutions per store.
4. **Rename the dev menu's "Wipe everything for testing"** to something
   user-facing like "Erase all my reflections" before submitting.
5. **App store reviewer notes** — Apple sometimes wants a demo account.
   Easiest path: anonymous-first means they don't strictly need one; if
   they ask, the app works without sign-in and you can say so.
6. **App tracking transparency disclosure** (Apple) — answer the
   "tracking" questions honestly: Liken does NOT track users, does NOT
   share data with third parties for advertising, and does NOT use any
   of the iOS tracking APIs. The "App Tracking Transparency" prompt is
   not required.

## Privacy policy stub (TODO: replace placeholders, host as a public URL)

```
# Liken Privacy Policy

Last updated: <date>

Liken is a personal devotional reflection app. We collect only what we
need to make the app work, and we never sell or share your data with
third parties for advertising.

## What we collect
- An account identifier (anonymous user id, or your email if you create
  an account).
- Your optional display name.
- The reflections you create — ratings, optional notes, timestamps,
  and the attribute you've chosen to focus on.

## Where it lives
Your data is stored in Google Cloud Firestore under a Firebase project
operated by the developer (Tyler Christensen). Access is restricted to your
account by Firestore security rules.

## What we share
Nothing. We do not sell your data, and we do not share it with third
parties for advertising or analytics. We do not use ad networks.

## How to delete your data
Open Liken → Settings → "Erase all my reflections". This removes
everything we've stored for you. You can also email <support@email>
and we'll delete it manually.

## Children
Liken is suitable for all ages. We do not knowingly collect data from
children under 13 except as described above.

## Contact
<support@email>
```
