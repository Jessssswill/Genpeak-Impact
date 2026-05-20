# GenPeak-Impact

GenPeak-Impact is an application that provides numerous Teyvat weapons and artifacts which the user can buy in the application.

> Note: Artifact assets used are Genshin Impact-inspired placeholders for academic prototyping only. Not affiliated with Hoyoverse.

## Roles & Features

There are 2 roles in the application:
- **Admin**: Can insert, update, and delete weapons.
- **User**: Can view and buy weapons. Users can buy as many weapons as they want.

**Weapon Specifications**: Must include ID, name, type, description, stock, image, and price.

---

## Project Requirements

### 1. Database (MySQL)
- The application must perform at least one create, one retrieve, one update, and one delete (CRUD) operation.

### 2. Front-End (Flutter Mobile App)
- Must have at least 5 kinds of UI components.
- Must have at least 5 pages.
- Must have at least 3 kinds of data validations.
- If any validation fails, the application must show an appropriate error message.

### 3. Back-End (Node.js, Express)
- Must implement at least 2 `GET` requests and 1 `POST` / `PUT` / `PATCH` / `DELETE` request.

### 4. Authentication
- Successfully log in using a user stored in the DB.
- Successfully log in using External OAuth (Google, Facebook, Twitter, etc.).
- Generate a bearer token. The token must be at least 20 characters long and alphanumeric.
- At least 1 request must include bearer token verification.

### 5. UI Design
- The application should be themed, involving changes to 2-4 properties (e.g., font size, font family, font color, background color, tint, alpha, content mode).
- All customizations should be visible in the application and noted in the documentation.
- The design should be usable and not hamper usability (e.g., sufficient contrast between font color and background color, colors should not clash).

### 6. External Documentation
- Must include external documentation explaining feature details and the creativity involved in the application.

---

## 📝 Asset Disclaimer

Artifact images located in `artifacts/` and `backend/public/images/artifacts/`
are **Genshin Impact-inspired references** used during academic prototyping.
These assets are placeholders to help iterate on game mechanics & UI quickly.

This project is for **academic purposes only** (Mobile Hybrid Solution course
at BINUS University) and is **not affiliated with Hoyoverse or Genshin Impact**.
Original artwork will replace these placeholders in any production release.

If you're cloning this repo for educational purposes, please respect
intellectual property and don't redistribute these assets commercially.