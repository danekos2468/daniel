#!/bin/bash
#
# NOVA FINANCE — Permission Investigation Lab
# Setup script for TECH4YOUTH instructors
#
# WHAT THIS DOES
#   Builds a fake company filesystem at /opt/nova_finance under a set of
#   real Linux users/groups, populates it with ~18 fictional company
#   documents, and deliberately misconfigures several permissions so
#   students can investigate them like real security tickets.
#
# REQUIREMENTS
#   - A disposable Linux box or VM (Ubuntu/Debian tested). DO NOT run
#     this on a shared or production machine — it creates real system
#     users and group memberships.
#   - Run as root: sudo bash setup_nova_finance_lab.sh
#
# TO TEAR DOWN
#   Run: sudo bash teardown_nova_finance_lab.sh   (included in this pack)
#
set -e

BASE=/opt/nova_finance

echo "== NOVA FINANCE Lab Setup =="

# ---------------------------------------------------------------------------
# 1. GROUPS
# ---------------------------------------------------------------------------
for g in finance hr it-staff management interns; do
    groupadd -f "$g"
done

# ---------------------------------------------------------------------------
# 2. USERS  (no login shell needed — these are role accounts for the lab)
# ---------------------------------------------------------------------------
# name            full role                         groups
useradd -M -N -s /usr/sbin/nologin -c "Diego Morales, Finance Manager"     dmorales      2>/dev/null || true
useradd -M -N -s /usr/sbin/nologin -c "Jamie Chen, Finance Analyst"        jchen         2>/dev/null || true
useradd -M -N -s /usr/sbin/nologin -c "Sara Wright, HR Manager"            swright       2>/dev/null || true
useradd -M -N -s /usr/sbin/nologin -c "Toby Ojo, HR Assistant"             tojo          2>/dev/null || true
useradd -M -N -s /usr/sbin/nologin -c "Raj Patel, IT Systems Admin"        rpatel        2>/dev/null || true
useradd -M -N -s /usr/sbin/nologin -c "Kim Bailey, IT Support"             kbailey       2>/dev/null || true
useradd -M -N -s /usr/sbin/nologin -c "Chloe Nguyen, CFO"                  cngu          2>/dev/null || true
useradd -M -N -s /usr/sbin/nologin -c "Amara Walsh, Marketing"             awalsh        2>/dev/null || true
useradd -M -N -s /usr/sbin/nologin -c "Sam Ibarra, Finance Intern"         intern_sam    2>/dev/null || true
useradd -M -N -s /usr/sbin/nologin -c "Pat Devine, FORMER Payroll Clerk (offboarded 2026-01-15, account never disabled)" former_employee 2>/dev/null || true

usermod -aG finance     dmorales
usermod -aG finance     jchen
usermod -aG hr          swright
usermod -aG hr,interns  tojo
usermod -aG it-staff    rpatel
usermod -aG it-staff    kbailey
usermod -aG management,finance cngu
usermod -aG finance,interns    intern_sam   # <-- MISCONFIG: intern has full finance group, not just training access
usermod -aG hr          former_employee     # <-- MISCONFIG: offboarded user still in hr group
# awalsh (marketing) deliberately gets NO department group — used to prove world-readable leaks

echo "Users/groups created."

# ---------------------------------------------------------------------------
# 3. FOLDER STRUCTURE
# ---------------------------------------------------------------------------
mkdir -p "$BASE"/{finance/payroll,finance/budgets,finance/invoices,\
hr/employee_records,hr/performance_reviews,hr/recruiting,\
it/backups,it/logs,it/configs,\
management/board_reports,management/strategy,\
shared/company_policies,shared/announcements,\
engineering/deploy_scripts}

chown root:root "$BASE"
chmod 755 "$BASE"

# ---------------------------------------------------------------------------
# 4. DEPARTMENT DOCUMENTS  (fictional content only)
# ---------------------------------------------------------------------------

# --- FINANCE ---
cat > "$BASE/finance/payroll/2026_salaries.csv" <<'EOF'
employee_id,name,department,annual_salary_usd
E-1001,Diego Morales,Finance,118000
E-1002,Jamie Chen,Finance,89000
E-1003,Sara Wright,HR,97000
E-1004,Toby Ojo,HR,54000
E-1005,Raj Patel,IT,104000
E-1006,Kim Bailey,IT,71000
E-1007,Chloe Nguyen,Management,182000
E-1008,Amara Walsh,Marketing,76000
E-1009,Sam Ibarra,Finance (Intern),34000
EOF

cat > "$BASE/finance/budgets/2026_dept_budget.txt" <<'EOF'
NOVA FINANCE — FY2026 Departmental Budget (DRAFT)
Finance:      $1,240,000
HR:             $410,000
IT:             $980,000
Marketing:      $650,000
Management:     $300,000
Notes: Pending board approval, do not circulate outside Finance.
EOF

cat > "$BASE/finance/invoices/vendor_invoice_884231.txt" <<'EOF'
Vendor: CloudGrid Hosting Services
Invoice #884231
Amount Due: $12,430.00
Due Date: 2026-10-15
Status: Pending approval (Finance)
EOF

cat > "$BASE/finance/README_finance.txt" <<'EOF'
Finance team shared drive. Payroll and budget files are CONFIDENTIAL —
Finance department access only. Do not share outside the group.
EOF

# --- HR ---
cat > "$BASE/hr/employee_records/personnel_files.txt" <<'EOF'
NOVA FINANCE — Personnel File Index (CONFIDENTIAL, HR ONLY)
E-1001 Diego Morales   - Hired 2019-03-01 - Performance: Exceeds
E-1002 Jamie Chen      - Hired 2022-06-14 - Performance: Meets
E-1003 Sara Wright     - Hired 2017-01-10 - Performance: Exceeds
E-1004 Toby Ojo        - Hired 2025-09-02 - Performance: New Hire
E-1007 Chloe Nguyen    - Hired 2015-04-22 - Performance: Exceeds
Includes home addresses and emergency contacts on file separately.
EOF

cat > "$BASE/hr/performance_reviews/2025_review_summary.txt" <<'EOF'
2025 Annual Review Summary (HR internal use only)
Overall satisfaction score: 4.1/5
Flight-risk flags: 1 (see confidential addendum, not stored digitally)
EOF

cat > "$BASE/hr/recruiting/open_reqs.txt" <<'EOF'
Open Requisitions — Q4 2026
- Senior Financial Analyst (Finance)
- Help Desk Technician (IT)
- Marketing Coordinator (Marketing)
EOF

# --- IT ---
cat > "$BASE/it/logs/auth_summary_sept2026.txt" <<'EOF'
NOVA FINANCE — IT Auth Log Summary (Sept 2026)
Failed login attempts (top offenders):
  awalsh    - 2 attempts (password typo, resolved)
  unknown   - 14 attempts against admin panel (blocked by firewall)
Full raw logs retained on syslog server, not on this share.
EOF

cat > "$BASE/it/backups/db_backup_full.sql.gz.txt" <<'EOF'
[placeholder for lab use — represents a compressed nightly database dump]
Contains: customer account records, transaction history, payroll table export.
Classification: HIGHLY CONFIDENTIAL — IT admins only.
EOF

cat > "$BASE/it/configs/db_admin_key.txt" <<'EOF'
-----BEGIN LAB-FAKE PRIVATE KEY-----
This file represents a private key used by automated backup jobs to
connect to the production database. It is FICTIONAL for lab purposes,
but in real life a private key with these permissions would be a
critical exposure.
-----END LAB-FAKE PRIVATE KEY-----
EOF

cat > "$BASE/it/README_it.txt" <<'EOF'
IT systems share. Backups and config/key material must never be
readable or writable outside the it-staff group.
EOF

# --- MANAGEMENT ---
cat > "$BASE/management/board_reports/q3_2026_board_summary.txt" <<'EOF'
NOVA FINANCE — Q3 2026 Board Summary (CONFIDENTIAL)
Revenue: $4.2M (+8% QoQ)
Runway: 21 months
Strategic initiative: expand into two new regional markets in 2027.
EOF

cat > "$BASE/management/strategy/2027_expansion_plan.txt" <<'EOF'
2027 Expansion Plan (DRAFT — Management eyes only)
Target markets: Pacific Northwest, Gulf Coast
Estimated capex: $1.8M
EOF

# --- SHARED / COMPANY-WIDE ---
cat > "$BASE/shared/company_policies/acceptable_use_policy.txt" <<'EOF'
NOVA FINANCE — Acceptable Use Policy (v3)
All employees must access only the data required for their role.
Sharing credentials or bypassing department access controls is a
violation of company policy and may result in termination.
EOF

cat > "$BASE/shared/company_policies/data_classification_policy.txt" <<'EOF'
Data Classification Policy
  PUBLIC        - shared/announcements
  INTERNAL      - department README files, recruiting postings
  CONFIDENTIAL  - budgets, personnel files, board reports
  RESTRICTED    - payroll, backups, key material
Restricted and Confidential data must never be world-readable.
EOF

cat > "$BASE/shared/announcements/all_staff_memo.txt" <<'EOF'
NOVA FINANCE — All-Staff Memo
Reminder: the building badge system will be upgraded this weekend.
Expect brief delays Monday morning. — Facilities
EOF

echo "Documents created."

# ---------------------------------------------------------------------------
# 5. OWNERSHIP + BASELINE (CORRECT) PERMISSIONS
# ---------------------------------------------------------------------------
chown -R root:finance    "$BASE/finance"
chown -R root:hr         "$BASE/hr"
chown -R root:it-staff   "$BASE/it"
chown -R root:management "$BASE/management"
chown -R root:root       "$BASE/shared"
chown -R root:root       "$BASE/engineering"

find "$BASE/finance"      -type d -exec chmod 750 {} \;
find "$BASE/finance"      -type f -exec chmod 640 {} \;
find "$BASE/hr"           -type d -exec chmod 750 {} \;
find "$BASE/hr"           -type f -exec chmod 640 {} \;
find "$BASE/it"           -type d -exec chmod 750 {} \;
find "$BASE/it"           -type f -exec chmod 640 {} \;
find "$BASE/management"   -type d -exec chmod 750 {} \;
find "$BASE/management"   -type f -exec chmod 640 {} \;
find "$BASE/shared"       -type d -exec chmod 755 {} \;
find "$BASE/shared"       -type f -exec chmod 644 {} \;

# ---------------------------------------------------------------------------
# 6. DELIBERATE MISCONFIGURATIONS  — one per investigation ticket
# ---------------------------------------------------------------------------

# TICKET-1: payroll file left world-readable
chmod 644 "$BASE/finance/payroll/2026_salaries.csv"

# TICKET-2: HR personnel file left world-writable
chmod 666 "$BASE/hr/employee_records/personnel_files.txt"

# TICKET-3: full database backup left world read/write/execute
chmod 777 "$BASE/it/backups/db_backup_full.sql.gz.txt"

# TICKET-4: excess group membership already set above (intern_sam in finance)
#           no file change needed — this ticket is about `id`/`groups` evidence

# TICKET-5: stale account already set above (former_employee still in hr)
#           no file change needed — this ticket is about account-audit evidence

# TICKET-6: all-staff memo owned by an intern with 777 (anyone can edit company memo)
chown intern_sam:interns "$BASE/shared/announcements/all_staff_memo.txt"
chmod 777 "$BASE/shared/announcements/all_staff_memo.txt"

# TICKET-7: "private key" file readable by everyone instead of owner-only
chown root:it-staff "$BASE/it/configs/db_admin_key.txt"
chmod 644 "$BASE/it/configs/db_admin_key.txt"

echo "Misconfigurations applied."
echo ""
echo "== Setup complete. Company root: $BASE =="
echo "See investigation_tickets.md for the student assignment."
