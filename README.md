# Leave Request Manager – SAP RAP Application

A leave request management app built with the **ABAP RESTful Application Programming Model (RAP)** on SAP BTP ABAP Environment.

---

## Features

- Create, update, and delete leave requests
- Set leave type (Annual / Sick / Casual) via a value help dropdown
- Filter list report by leave type and status
- Status automatically set to **Pending (P)** on creation
- Leave days automatically calculated from start date and end date
- Validation that rejects requests where the end date is before the start date
- **Approve** and **Reject** actions — both buttons grey out after a decision
- Full Fiori draft flow: Create → Edit → Save with discard/resume support

---

## Project Overview – ADT (Eclipse)

> The full object tree of the ZLEAVE_REQUEST package in SAP ADT (Eclipse), showing all objects: Business Services, CDS Views, BDEFs, Dictionary Tables, and Classes.

![ADT Project Overview](docs/screenshots/overview.png)

---

## Repository Structure

```
leave-request-manager/
├── src/
│   ├── classes/                                          # ABAP Classes
│   │   ├── zbp_i_leave.clas.abap                         # Behaviour pool (global shell)
│   │   ├── zbp_i_leave.clas.locals_imp.abap              # Local handler (lhc_Leave)
│   │   └── zcl_lr_load_data.clas.abap                    # Seed data loader (run with F9)
│   ├── database-tables/                                  # Dictionary Tables
│   │   ├── zlr_ltype.tabl.txt                            # Leave type master data
│   │   ├── zlr_leave.tabl.txt                            # Leave request table
│   │   └── zlr_leave_d.tabl.txt                          # Draft table for ZI_LEAVE
│   ├── data-definitions/                                 # CDS Views
│   │   ├── zi_leave.ddls.asddls                          # Interface view (root entity)
│   │   ├── zc_leave.ddls.asddls                          # Projection / consumption view
│   │   └── zi_ltype_vh.ddls.asddls                       # Leave type value help
│   ├── behavior-definitions/                             # BDEFs
│   │   ├── zi_leave.bdef.asbdef                          # Interface BDEF (managed + draft)
│   │   └── zc_leave.bdef.asbdef                          # Projection BDEF
│   ├── metadata-extensions/                              # UI Annotations
│   │   └── zc_leave.ddlx.asddlxs                         # List report + object page layout
│   ├── access-controls/                                  # DCLS
│   │   └── zi_leave.dcls.asdcls                          # Authorization check
│   └── service-definitions/                              # Service / Binding
│       └── zui_leave.srvd.srvdsrv                        # OData V4 service definition
├── docs/
│   └── screenshots/
│       ├── overview.png
│       ├── list_report.png
│       ├── create_request.png
│       ├── object_page.png
│       ├── error_end_date.png
│       └── approved_request.png
└── README.md
```

---

## Screenshots

### List Report – All Requests
> The main list report showing all leave requests with Employee, Leave Type, Start/End Date, Days, and Status. Filter bar shows Leave Type and Status dropdowns.

![List Report](docs/screenshots/list_report.png)

---

### Create New Request
> The draft form to fill in Employee, Leave Type (value help — Annual AL / Sick SL / Casual CL), Start Date, End Date, and Reason.

![Create Request](docs/screenshots/create_request.png)

---

### Object Page
> Object page showing a saved request with all fields and the Approve / Reject action buttons.

![Object Page](docs/screenshots/object_page.png)

---

### Validation Error – End Date Before Start Date
> Error message raised by `validateDates` when the end date is earlier than the start date.

![End Date Error](docs/screenshots/error_end_date.png)

---

### Approved Request
> A request after clicking Approve: status changes to A and both Approve and Reject buttons are greyed out.

![Approved Request](docs/screenshots/approved_request.png)

---

## How to Run

1. Log on to your SAP BTP ABAP Environment system in **ADT (Eclipse)**.
2. Import or recreate all objects from the `src/` folder in the order below.
3. Activate all objects.
4. Publish the service binding **ZUI_LEAVE_O4** and open the Fiori preview.

### Import Order

| # | Object | Type | Folder |
|---|--------|------|--------|
| 1 | `ZLR_LTYPE` | Database Table | `database-tables/` |
| 2 | `ZLR_LEAVE` | Database Table | `database-tables/` |
| 3 | `ZLR_LEAVE_D` | Database Table (Draft) | `database-tables/` |
| 4 | `ZCL_LR_LOAD_DATA` | ABAP Class (run F9) | `classes/` |
| 5 | `ZI_LTYPE_VH` | CDS Value Help | `data-definitions/` |
| 6 | `ZI_LEAVE` | CDS Interface View | `data-definitions/` |
| 7 | `ZC_LEAVE` | CDS Projection View | `data-definitions/` |
| 8 | `ZI_LEAVE` (BDEF) | Behaviour Definition | `behavior-definitions/` |
| 9 | `ZC_LEAVE` (BDEF) | Behaviour Definition | `behavior-definitions/` |
| 10 | `ZBP_I_LEAVE` | Behaviour Pool Class | `classes/` |
| 11 | `ZC_LEAVE` (DDLX) | Metadata Extension | `metadata-extensions/` |
| 12 | `ZI_LEAVE` (DCLS) | Access Control | `access-controls/` |
| 13 | `ZUI_LEAVE` | Service Definition | `service-definitions/` |

---

## Problems Hit and Fixed

### 1 – `days` is a reserved word in table definitions
The field name `days` caused an activation error because it is a reserved keyword in ABAP Dictionary.  
**Fix:** renamed the table column to `leave_days` and the CDS alias to `LeaveDays`.

### 2 – `calculateDays` determination failed to activate
The original code used a `WHERE` condition inside a `FOR` expression inside `MODIFY ENTITIES … WITH VALUE #( FOR … WHERE … )`. The syntax checker raised *"STARTDATE is unknown"* and refused to activate.  
**Fix:** rewrote the determination as a `LOOP AT leaves INTO DATA(lv) WHERE …` block that builds an explicit update internal table (`updates`) and then calls `MODIFY ENTITIES … WITH updates`.

### 3 – Service wouldn't open: UI5 component could not be loaded
After binding, clicking "Preview" gave "UI5 component could not be loaded". Checking `$metadata` revealed that the entity alias `Leave` generated an entity type called `LeaveType`, which clashed with the `LeaveType` property name on the same entity.  
**Fix:** renamed the service binding alias from `Leave` to `LeaveRequest` in `ZUI_LEAVE.srvd.srvdsrv`, so the generated entity type became `LeaveRequestType`, eliminating the conflict.

---

## Test Checklist

- [ ] End date before start date → error message appears
- [ ] 10–12 June → 3 days, Status = P (Pending)
- [ ] Change end date to 14 June → recalculates to 5 days
- [ ] Approve button sets Status = A and greys out both buttons
- [ ] Reject button sets Status = R and greys out both buttons
- [ ] Leave Type dropdown shows Annual (AL), Sick (SL), Casual (CL)
- [ ] Empty Employee Name → mandatory field error

---

## Technologies Used

- SAP BTP ABAP Environment (Steampunk)
- ABAP RESTful Application Programming Model (RAP) with Draft
- Core Data Services (CDS)
- SAP Fiori Elements (List Report + Object Page)
- Instance Feature Control (action button enable/disable by status)

---

## What Makes This Different from Task Tracker

| Feature | Task Tracker | Leave Request Manager |
|---------|-------------|----------------------|
| Actions | 1 (markComplete) | 2 (Approve, Reject) |
| Determinations | 1 (setInitialStatus) | 2 (setInitialStatus + calculateDays) |
| Validations | 1 (validateDueDate) | 1 (validateDates – two-field comparison, fires on create + update) |
| Feature control | None | `get_instance_features` — Approve/Reject grey out after decision |
| Value help filter | Priority | Leave Type + Status |
| Leave type codes | — | 2-char: AL / SL / CL |

---

## Author

Rahul  
Built as a learning project following the RAP developer guide.
