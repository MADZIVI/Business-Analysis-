GreenCrunch Pickle Manufacturing — Database & REA Demonstration

Business Analysis 2.2 (AIBTY2A / AIFYT2A) — Vaal University of Technology, Faculty of Applied & Computer Sciences

A complete relational database design and SQL demonstration for **GreenCrunch Pickle Manufacturing (Pty) Ltd**, a South African SME producing premium pickles. Built around the REA (Resources–Events–Agents) accounting model covering the Sales & Collection, Acquisition & Payment, and Conversion cycles.

![Database](https://img.shields.io/badge/DB-MySQL%208-blue) ![SQLite](https://img.shields.io/badge/Demo-SQLite%203-lightgrey) ![NF](https://img.shields.io/badge/Normalisation-3NF-green) ![License](https://img.shields.io/badge/License-MIT-yellow)

---

## Table of Contents

- [Business Overview](#-business-overview)
- [REA Model](#-rea-model)
- [Schema Design (3NF)](#-schema-design-3nf)
- [Features Demonstrated](#-features-demonstrated)
- [Getting Started](#-getting-started)
- [Usage Examples](#-usage-examples)
- [Query Optimisation](#-query-optimisation)
- [Integration Problems Solved](#-integration-problems-solved)
- [References](#-references)

---

##  Business Overview

GreenCrunch produces sweet, spicy, garlic, and mixed-vegetable pickles for retail, wholesale, and food-service customers across South Africa.

| Cycle | Purpose | Key Entities |
| --- | --- | --- |
| **Acquisition & Payment** | Buy raw materials (cucumbers, vinegar, spices, jars) | Raw vegetables, Cash / Purchase order, Purchase, Cash disbursement / Supplier, Procurement officer |
| **Conversion** | Transform raw materials into finished pickles | Raw materials → Finished goods / Requisition, Production run, Quality check / Production supervisor, Employees |
| **Sales & Collection** | Sell pickles and collect payment (core cycle modelled here) | Finished goods, Cash / Order, Sale, Cash receipt / Customer, Sales rep, Cashier |

---

##  REA Model

REA diagrams model **Resources** (things of value), **Events** (what happens to them), and **Agents** (who participates), with cardinality pairs `(min,max)` on every relationship.

- **Sales & Collection:** Customer inquiry → Order (mutual commitment) → Sale (decrement of finished goods) ⇄ Cash receipt (increment of cash) — linked by a *duality* relationship.
- **Acquisition & Payment:** Purchase requisition → Purchase order → Purchase (increment of raw materials) ⇄ Cash disbursement (decrement of cash).
- The three cycles integrate through shared resources: *inventory* links Acquisition → Conversion, and *cash* links Payment → Collection.

---

## Schema Design (3NF)

Normalised from a flat UNF order export:

1. **1NF** — atomic values, repeating groups split into `Order_Line`
2. **2NF** — line attributes depend on the whole composite key `(order_id, product_id)`
3. **3NF** — transitive dependencies removed (`Customer`, `Product`, `Payment` in own tables)

```
Customer(customer_id PK, customer_name, phone UNIQUE)
Product(product_id PK, product_name, unit_price CHECK(>0), qty_in_stock CHECK(>=0))
Sales_Order(order_id PK, order_date, customer_id → Customer)
Order_Line(order_id, product_id, qty, unit_price, PK(order_id, product_id),
           order_id → Sales_Order, product_id → Product)
Payment(payment_id PK, order_id → Sales_Order UNIQUE, pay_date,
        pay_method CHECK IN ('Cash','EFT','Card'), amount CHECK(>0))
```


 🔗 Integration Problems Solved

| Problem | Solution in this design |
| --- | --- |
| Duplicate supplier records | Surrogate PKs + `UNIQUE` constraints |
| Inconsistent stock levels | `trg_stock_out` trigger updates stock in real time |
| Payments unlinked from orders | `Payment.order_id UNIQUE` FK + validating procedure |
| Production/sales mismatch | Single integrated schema — one source of truth |
| Manual entry errors | `CHECK`/`NOT NULL` constraints reject invalid data at the DB level |

---

References

- Dunn, Cherrington & Hollander (2004) — *REA Accounting Model*
- Romney & Steinbart (2021) — *Accounting Information Systems*, 15th edn.
- Hall (2021) — *Accounting Information Systems*, 10th edn.
- Laudon & Laudon (2022) — *Management Information Systems*, 17th edn.

Business Rules

| Rule | Enforcement |
|---|---|
| **BR-01** Every entity has a unique surrogate key | `PRIMARY KEY` on every table |
| **BR-02** An order belongs to exactly one existing customer | `FOREIGN KEY (customer_id) → Customer` |
| **BR-03** One payment per order | `UNIQUE(order_id)` in `Payment` |
| **BR-04** Payment must equal the order total | `sp_record_payment` procedure (rejects mismatches with `SIGNAL`) |
| **BR-05** Prices must be above R0 | `CHECK (unit_price > 0)` |
| **BR-06** Stock can never go negative | `CHECK (qty_in_stock >= 0)` + trigger |
| **BR-07** Line quantities must be positive | `CHECK (qty > 0)` |
| **BR-08** Payment method limited to Cash/EFT/Card | `ENUM('Cash','EFT','Card')` |
| **BR-09** Customer phones unique | `UNIQUE` constraint |
| **BR-10** Stock auto-decrements when a line is sold | `trg_stock_out` trigger |
| **BR-11** Purchase orders reference approved suppliers | `FOREIGN KEY (supplier_id) → Supplier` |
| **BR-12** No future-dated orders | `CHECK (order_date <= CURDATE())` |

## South African data (20+ records per table, 8 tables)

- **20 Suppliers** — FreshFarm Cucumbers, Karoo Veg Co, Ubuntu Spices… across all 9 provinces (Gauteng, Western Cape, KZN, Limpopo…)
- **20 Raw materials** — cucumbers, vinegar, spices, glass jars, priced in Rand, linked to suppliers by FK
- **20 Customers** — Soweto SuperSpar, Boxer Superstore, Braai & Spice House… with SA cell numbers (071/082/073 format), `.co.za` emails, and provincial cities
- **20 Products** — 20 pickle varieties priced R50–R120, e.g. Peri-Peri Pickle R66, Sampler Gift Pack R120
- **22 Sales orders** + **~44 order lines** across October 2025, **20 Payments**, **20 Purchase orders** (covering the Acquisition cycle too)

<sub>Academic group assignment — Business Analysis 2.2, Computer Science Department, VUT.</sub>
