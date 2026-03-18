# Installed Software Auditor

A PowerShell script to audit recently installed software on Windows endpoints.

## 🔍 Features

* Collects installed software from:

  * 64-bit registry
  * 32-bit registry
* Filters software installed in the last **X days**
* Uses fallback detection if install date is missing:

  * Registry InstallDate
  * Install folder timestamp
* Exports results to CSV
* Designed for:

  * RMM tools (Atera, etc.)
  * Security audits
  * Endpoint inventory

---

## 📁 Script

`Get-InstalledSoftwareAudit.ps1`

---

## ⚙️ Usage

### Default (last 10 days)

```powershell
.\Get-InstalledSoftwareAudit.ps1
```

### Last 15 days

```powershell
.\Get-InstalledSoftwareAudit.ps1 -Days 15
```

### Custom export location

```powershell
.\Get-InstalledSoftwareAudit.ps1 -Days 15 -ExportPath "C:\Temp\audit.csv"
```

---

## 📊 Example Output (CSV)

| ComputerName | Name    | Version | Publisher    | InstallDate | Source   |
| ------------ | ------- | ------- | ------------ | ----------- | -------- |
| PC-01        | Chrome  | 122.0   | Google       | 2026-03-10  | Registry |
| PC-01        | AnyDesk | 8.0     | AnyDesk GmbH | 2026-03-12  | Folder   |

---

## 🧠 Notes

* Not all applications populate `InstallDate` in the registry.
* This script improves detection using folder timestamps.
* Results may vary depending on installer behavior.

---

## 🚀 Use Cases

* Detect newly installed software
* Security investigations
* Remote endpoint auditing
* Change tracking

---

## 👨‍💻 Author

Bradley Mclaughlan
