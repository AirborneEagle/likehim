# Like Him — Play Store / App Store listing copy

Pre-written copy you can paste into Google Play Console and App Store Connect
when you're ready to submit. Edit to taste, but it's all here so you don't
have to write it from scratch under deadline pressure.

---

## App name (30 char limit)

> Like Him

(The Play Store also asks for a "short name" — same.)

## Short description / subtitle (80 char limit)

> A quiet companion for becoming more like the Savior.

## Full description (4000 char limit on Play, 4000 on App Store)

> Like Him is a quiet companion for becoming more like the Savior — built around
> the **Christlike Attribute Activity** from chapter 6 of *Preach My Gospel:
> A Guide to Sharing the Gospel of Jesus Christ* (2023).
>
> You take a gentle, prayerful self-assessment, rating each statement under
> ten attributes — Faith, Hope, Charity & Love, Virtue, Integrity, Knowledge,
> Patience, Humility, Diligence, and Obedience — on the *Never → Always*
> scale. Like Him remembers your reflections forever and shows you, quietly, how
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
> Like Him is not a scoreboard. There are no streaks, no badges, no
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

**https://likehim.app/privacy** — hosted on the marketing Firebase Hosting
target, source at [marketing/privacy.html](marketing/privacy.html). Both
stores require a public URL; this one is canonical.

## Data safety / App Privacy declaration

**Data Like Him collects** (be honest with the stores about this):

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
left, the words **Like Him** and *a quiet companion for becoming* on the
right in Fraunces / Inter. I haven't built a generator for this — see
TODO at the end of this doc.

## What's new (release notes, 500 char limit)

> First release. Take a quiet self-reflection across the ten Christlike
> attributes. Your reflections sync across devices and stay yours.

## Support email / website

- **Email:** support@likehim.app (forwards to Tyler's personal inbox)
- **Website:** https://likehim.app
- **Privacy policy:** https://likehim.app/privacy

## Pricing & monetization

Free, no ads, no in-app purchases, no subscriptions. (Edit later if you
change direction.)

## Countries / availability

Suggest: all countries / all languages (it's English-only for now, but
both stores accept that).

---

## Things still to do before you can submit

Tracked in GitHub issues — see master tracker [#27](https://github.com/AirborneEagle/likehim/issues/27).

A few notes that don't have a natural home in the issues themselves:

1. **App store reviewer notes** — Apple sometimes wants a demo account.
   We don't need one because of anonymous-first sign-in. The reviewer
   notes in issue #19 spell this out: "Tap 'Try Like Him without an
   account' on the auth screen to use the app without creating one."
2. **App Tracking Transparency** (Apple) — answer the tracking questions
   honestly: Like Him does NOT track users, does NOT share data with
   third parties for advertising, and does NOT use any of the iOS
   tracking APIs. The ATT prompt is not required.
3. **Sign in with Apple** — required by Apple Review Guideline 4.8 since
   we offer Google sign-in. Code lands in issue #9; this was the single
   biggest pre-submission blocker.

## Privacy policy

Lives at https://likehim.app/privacy. Source: [marketing/privacy.html](marketing/privacy.html).
