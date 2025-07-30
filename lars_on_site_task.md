# On‑Site Flutter Coding Challenge – Gym Calendar View

## 1. Objective

Design and implement a **calendar view** in Flutter that helps users discover open time slots in multiple sports locations (gyms) and their rooms, while clearly blocking off slots that are already reserved by scheduled sport courses.

We want to see how you structure a small but non‑trivial feature end‑to‑end: domain modelling, state management, custom UI, and clean code.

---

## 2. Scenario

Our company operates several gyms. Each gym has one or more **rooms** (e.g., “Studio A”, “Court 2”). Courses such as *Yoga Basics* or *Spinning* reserve blocks of time in those rooms.  Outside those course blocks, members may book the room for individual workouts.

Your task is to build a calendar widget that:

1. Lists the available **locations** and their **rooms**.
2. Shows a **time‑grid** of one weekday (e.g. 06:00 – 22:00 in 30‑min slots).
3. Visually distinguishes **available** vs **booked** slots.  Booked slots display the course name and are non‑interactive.
4. Lets the user tap an available slot to start a mock booking flow (show a simple confirmation sheet is enough).

---

## 3. Functional Requirements

|  ID | Requirement                                                                                                            |
| --- | ---------------------------------------------------------------------------------------------------------------------- |
| F‑1 | **Date switcher** – user can move forward/back by day.                                                                 |
| F‑2 | **Location selector** – list gyms in a dropdown or side panel.                                                         |
| F‑3 | **Room tabs/columns** – within a gym, users can switch between rooms.                                                  |
| F‑4 | **Time grid** – 06:00 → 22:00, 15‑min increments (configurable).                                                       |
| F‑5 | **Booked block rendering** – continuous colored bar spanning the start→end range, labelled with the course title.      |
| F‑6 | **Availability interaction** – tapping a free slot triggers a dialog with the chosen location, room, start & end time. |
| F‑7 | **Responsiveness** – graceful layout on phone portrait, phone landscape, and tablet.                                   |

### Stretch (pick any if you finish core):

* **Week view** – render seven consecutive days in a horizontal scroll.
* **Virtual scrolling** for large time ranges.
* **Unit/widget tests** for critical logic.

---

## 4. Non‑Functional & Technical Constraints

* **Flutter ≥ 3.30** (stable channel).
* You may use any packages **except** ready‑made calendar UI libraries (e.g., table\_calendar/full\_calendar) – we want to assess custom rendering.
* State management: Provider, Riverpod, Bloc, or ValueNotifier – choose one and justify it.
* Aim for clean architecture (separate presentation, domain, data).
* Document your decisions in code comments or a short `DECISIONS.md`.

---

## 5. Data & Mock API

Use the following static JSON as your data source (feel free to place it in `assets/fixtures` and load via `rootBundle.loadString`).

```json
{
  "locations": [
    {
      "id": "loc_1",
      "name": "Downtown Gym",
      "rooms": [
        { "id": "room_1", "name": "Studio A" },
        { "id": "room_2", "name": "Court 1" }
      ]
    },
    {
      "id": "loc_2",
      "name": "Riverside Gym",
      "rooms": [
        { "id": "room_3", "name": "Spin Room" }
      ]
    }
  ],
  "bookings": [
    {
      "roomId": "room_1",
      "course": "Yoga Basics",
      "start": "2025-07-14T09:00:00",
      "end":   "2025-07-14T10:30:00"
    },
    {
      "roomId": "room_2",
      "course": "HIIT Express",
      "start": "2025-07-14T18:00:00",
      "end":   "2025-07-14T19:00:00"
    },
    {
      "roomId": "room_3",
      "course": "Spinning Marathon",
      "start": "2025-07-14T12:00:00",
      "end":   "2025-07-14T14:00:00"
    }
  ]
}
```

> **Tip**: Derive the list of available 15‑min slots by scanning each room’s timeline and excluding the ranges covered by bookings.

---

## 6. Deliverables (end of on‑site day)

1. A runnable Flutter project in a public Git repository (GitHub/GitLab) or zipped folder.
2. `README.md` with build/run instructions and a 2‑minute architecture overview.
3. The calendar screen fulfilling F‑1 → F‑7.
4. (Optional) Any stretch goals you achieved, documented in the README.

---

## 7. Suggested Timeline (4 h total)

| Time        | Activity                                 |
| ----------- | ---------------------------------------- |
| 0:00 – 0:15 | Clarify requirements & set up project    |
| 0:15 – 1:15 | Data modelling & slot calculation logic  |
| 1:15 – 2:45 | Build calendar UI & interactions         |
| 2:45 – 3:15 | Polish responsive design & accessibility |
| 3:15 – 3:45 | Write tests & README                     |
| 3:45 – 4:00 | Final demo              |

---

## 9. Hints & Allowed Resources

* Feel free to use any AI tools, but make sure to verify output and double check logic
* Keep commits small and labelled (`feat`, `fix`, etc.).

Good luck! We’re excited to see your solution.
