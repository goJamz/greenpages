import fs from 'node:fs'

const auditFilePath = process.argv[2] || '/tmp/npm-audit.json'

try {
  const audit = JSON.parse(fs.readFileSync(auditFilePath, 'utf8'))
  const counts = audit.metadata?.vulnerabilities || {}
  const total = counts.total || 0
  const vulnerabilities = audit.vulnerabilities || {}

  console.log(
    `NPM AUDIT SUMMARY: critical=${counts.critical || 0} high=${counts.high || 0} moderate=${counts.moderate || 0} low=${counts.low || 0} info=${counts.info || 0} total=${total}`,
  )

  for (const [packageName, finding] of Object.entries(vulnerabilities)) {
    console.log(
      `NPM AUDIT FINDING: package=${packageName} severity=${finding.severity} range=${finding.range} fixAvailable=${JSON.stringify(finding.fixAvailable)}`,
    )
  }

  if (total === 0) {
    console.log('NPM AUDIT FINDINGS: none')
  }
} catch (error) {
  console.log('NPM AUDIT SUMMARY: unable to parse npm audit output')
  console.log(String(error))
}
