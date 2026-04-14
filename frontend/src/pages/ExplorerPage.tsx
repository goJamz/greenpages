import { useEffect, useMemo, useState } from 'react'
import { Link, useSearchParams } from 'react-router'
import {
  buildExportPositionsURL,
  getExplorerPositions,
  type ExplorerAvailableOptions,
  type ExplorerPositionResult,
} from '../api/greenpages'
import { renderStatusBadge } from '../components/StatusBadge'

const componentOptions = [
  { value: 'Active', label: 'Active' },
  { value: 'Guard', label: 'Guard' },
  { value: 'Reserve', label: 'Reserve' },
]

const statusOptions = [
  { value: 'filled', label: 'Filled' },
  { value: 'vacant', label: 'Vacant' },
  { value: 'unknown', label: 'Unknown' },
]

const officerGradeOptions = [
  { value: 'COL', label: 'COL' },
  { value: 'LTC', label: 'LTC' },
  { value: 'MAJ', label: 'MAJ' },
  { value: 'CPT', label: 'CPT' },
]

const warrantOfficerGradeOptions = [
  { value: 'CW3', label: 'CW3' },
]

const enlistedGradeOptions = [
  { value: 'SGM', label: 'SGM' },
  { value: 'MSG', label: 'MSG' },
  { value: 'SFC', label: 'SFC' },
  { value: 'SSG', label: 'SSG' },
]

const branchOptions = [
  { value: 'AG', label: 'AG — Adjutant General' },
  { value: 'AR', label: 'AR — Armor' },
  { value: 'AV', label: 'AV — Aviation' },
  { value: 'CY', label: 'CY — Cyber' },
  { value: 'EN', label: 'EN — Engineer' },
  { value: 'FA', label: 'FA — Field Artillery' },
  { value: 'IN', label: 'IN — Infantry' },
  { value: 'LG', label: 'LG — Logistics' },
  { value: 'MI', label: 'MI — Military Intelligence' },
  { value: 'MS', label: 'MS — Medical Service' },
  { value: 'OD', label: 'OD — Ordnance' },
  { value: 'SC', label: 'SC — Signal' },
]

const mosOptions = [
  { value: '11B', label: '11B — Infantryman' },
  { value: '11Z', label: '11Z — Infantry Senior Sergeant' },
  { value: '12B', label: '12B — Combat Engineer' },
  { value: '13Z', label: '13Z — Field Artillery Senior Sergeant' },
  { value: '19Z', label: '19Z — Armor Senior Sergeant' },
  { value: '25B', label: '25B — IT Specialist' },
  { value: '25D', label: '25D — Cyber Network Defender' },
  { value: '25S', label: '25S — SATCOM Operator' },
  { value: '25U', label: '25U — Signal Support Specialist' },
  { value: '35F', label: '35F — Intelligence Analyst' },
  { value: '35N', label: '35N — SIGINT Analyst' },
  { value: '42A', label: '42A — Human Resources Specialist' },
  { value: '92A', label: '92A — Automated Logistical Specialist' },
  { value: '92Y', label: '92Y — Unit Supply Specialist' },
]

const aocOptions = [
  { value: '11A', label: '11A — Infantry' },
  { value: '12A', label: '12A — Engineer' },
  { value: '13A', label: '13A — Field Artillery' },
  { value: '15A', label: '15A — Aviation' },
  { value: '17A', label: '17A — Cyber Operations' },
  { value: '19A', label: '19A — Armor' },
  { value: '25A', label: '25A — Signal' },
  { value: '35A', label: '35A — Military Intelligence' },
  { value: '42A', label: '42A — Adjutant General' },
  { value: '59A', label: '59A — Strategic Plans and Policy' },
  { value: '70A', label: '70A — Health Services Administration' },
  { value: '90A', label: '90A — Logistics' },
  { value: '91A', label: '91A — Maintenance' },
]

const pinnedOconusStateOptions = [
  { value: 'AA', label: 'AA — Americas' },
  { value: 'AE', label: 'AE — Europe' },
  { value: 'AP', label: 'AP — Pacific' },
]

const conusStateOptions = [
  { value: 'AZ', label: 'AZ' },
  { value: 'CA', label: 'CA' },
  { value: 'CO', label: 'CO' },
  { value: 'GA', label: 'GA' },
  { value: 'HI', label: 'HI' },
  { value: 'IL', label: 'IL' },
  { value: 'KY', label: 'KY' },
  { value: 'LA', label: 'LA' },
  { value: 'MN', label: 'MN' },
  { value: 'NC', label: 'NC' },
  { value: 'NY', label: 'NY' },
  { value: 'PA', label: 'PA' },
  { value: 'TX', label: 'TX' },
  { value: 'VA', label: 'VA' },
  { value: 'WA', label: 'WA' },
]

// filterOptionsByAvailable narrows a static option array to only the values
// the backend reports as available for the current filter combination.
// The currently selected value is always kept visible so the user does not
// see their selection disappear from the dropdown.
// Returns all options when availableValues is null (initial load).
function filterOptionsByAvailable(
  options: { value: string; label: string }[],
  availableValues: string[] | null,
  currentSelection: string,
): { value: string; label: string }[] {
  if (availableValues === null) {
    return options
  }

  return options.filter((option) =>
    availableValues.includes(option.value) || option.value === currentSelection,
  )
}

// buildAdditionalStateOptions surfaces backend-returned state codes that are
// not already covered by the pinned OCONUS list or the known CONUS list.
// This prevents unknown future codes from getting shoved into the wrong group.
function buildAdditionalStateOptions(
  availableValues: string[] | null,
  currentSelection: string,
): { value: string; label: string }[] {
  const knownStateCodes = new Set([
    ...pinnedOconusStateOptions.map((option) => option.value),
    ...conusStateOptions.map((option) => option.value),
  ])
  const additionalValues = new Set<string>()
  const sortedAdditionalValues: string[] = []

  if (availableValues !== null) {
    availableValues.forEach((stateValue) => {
      if (stateValue !== '' && !knownStateCodes.has(stateValue)) {
        additionalValues.add(stateValue)
      }
    })
  }

  if (currentSelection !== '' && !knownStateCodes.has(currentSelection)) {
    additionalValues.add(currentSelection)
  }

  sortedAdditionalValues.push(...additionalValues)
  sortedAdditionalValues.sort()

  return sortedAdditionalValues.map((stateValue) => ({
    value: stateValue,
    label: stateValue,
  }))
}

function ExplorerPage() {
  const [searchParams, setSearchParams] = useSearchParams()

  const componentParam = searchParams.get('component') || ''
  const gradeParam = searchParams.get('grade') || ''
  const branchParam = searchParams.get('branch') || ''
  const mosParam = searchParams.get('mos') || ''
  const aocParam = searchParams.get('aoc') || ''
  const stateParam = searchParams.get('state') || ''
  const statusParam = searchParams.get('status') || ''

  const [results, setResults] = useState<ExplorerPositionResult[]>([])
  const [resultCount, setResultCount] = useState(0)
  const [availableOptions, setAvailableOptions] = useState<ExplorerAvailableOptions | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [errorMessage, setErrorMessage] = useState('')

  useEffect(() => {
    let isCancelled = false

    async function loadPositions() {
      if (!isCancelled) {
        setIsLoading(true)
        setErrorMessage('')
      }

      try {
        const explorerResponse = await getExplorerPositions(
          {
            component: componentParam,
            grade: gradeParam,
            branch: branchParam,
            mos: mosParam,
            aoc: aocParam,
            state: stateParam,
            status: statusParam,
          },
          100,
          0,
        )

        if (!isCancelled) {
          setResults(explorerResponse.results)
          setResultCount(explorerResponse.count)
          setAvailableOptions(explorerResponse.available_options)
        }
      } catch (fetchError) {
        if (!isCancelled) {
          setResults([])
          setResultCount(0)
          setAvailableOptions(null)

          if (fetchError instanceof Error) {
            setErrorMessage(fetchError.message)
          } else {
            setErrorMessage('Failed to load positions')
          }
        }
      } finally {
        if (!isCancelled) {
          setIsLoading(false)
        }
      }
    }

    loadPositions()

    return () => {
      isCancelled = true
    }
  }, [
    componentParam,
    gradeParam,
    branchParam,
    mosParam,
    aocParam,
    stateParam,
    statusParam,
  ])

  function setFilterParam(filterKey: string, filterValue: string) {
    setSearchParams((previousParams) => {
      let nextParams: URLSearchParams = new URLSearchParams(previousParams)
      let trimmedFilterValue: string

      trimmedFilterValue = filterValue.trim()

      if (trimmedFilterValue === '') {
        nextParams.delete(filterKey)
      } else {
        nextParams.set(filterKey, trimmedFilterValue)
      }

      return nextParams
    })
  }

  function handleClearFilters() {
    setSearchParams({})
  }

  function handleExportCSV() {
    let exportURL: string

    exportURL = buildExportPositionsURL({
      component: componentParam,
      grade: gradeParam,
      branch: branchParam,
      mos: mosParam,
      aoc: aocParam,
      state: stateParam,
      status: statusParam,
    })

    window.location.assign(exportURL)
  }

  const hasActiveFilters =
    componentParam !== '' ||
    gradeParam !== '' ||
    branchParam !== '' ||
    mosParam !== '' ||
    aocParam !== '' ||
    stateParam !== '' ||
    statusParam !== ''

  const visibleComponentOptions = filterOptionsByAvailable(
    componentOptions,
    availableOptions?.components ?? null,
    componentParam,
  )
  const visibleStatusOptions = filterOptionsByAvailable(
    statusOptions,
    availableOptions?.statuses ?? null,
    statusParam,
  )
  const visibleOfficerGradeOptions = filterOptionsByAvailable(
    officerGradeOptions,
    availableOptions?.grades ?? null,
    gradeParam,
  )
  const visibleWarrantOfficerGradeOptions = filterOptionsByAvailable(
    warrantOfficerGradeOptions,
    availableOptions?.grades ?? null,
    gradeParam,
  )
  const visibleEnlistedGradeOptions = filterOptionsByAvailable(
    enlistedGradeOptions,
    availableOptions?.grades ?? null,
    gradeParam,
  )
  const visibleBranchOptions = filterOptionsByAvailable(
    branchOptions,
    availableOptions?.branches ?? null,
    branchParam,
  )
  const visibleMosOptions = filterOptionsByAvailable(
    mosOptions,
    availableOptions?.mos_codes ?? null,
    mosParam,
  )
  const visibleAocOptions = filterOptionsByAvailable(
    aocOptions,
    availableOptions?.aoc_codes ?? null,
    aocParam,
  )

  // AA / AE / AP stay pinned and visible by design.
  const visiblePinnedOconusStateOptions = pinnedOconusStateOptions

  const visibleConusStateOptions = filterOptionsByAvailable(
    conusStateOptions,
    availableOptions?.states ?? null,
    stateParam,
  )

  const visibleAdditionalStateOptions = useMemo(
    () => buildAdditionalStateOptions(availableOptions?.states ?? null, stateParam),
    [availableOptions, stateParam],
  )

  return (
    <main className="min-h-screen bg-slate-100 text-slate-900">
      <div className="mx-auto flex max-w-7xl flex-col gap-6 px-4 py-10 sm:px-6 lg:px-8">
        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">
                Green Pages
              </p>

              <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-900">
                Position Explorer
              </h1>

              <p className="mt-3 max-w-3xl text-sm leading-6 text-slate-600">
                Browse billets across the force. Use filters to narrow by component, grade,
                branch, MOS, AOC, state, or status.
              </p>
            </div>

            <div className="shrink-0">
              <Link
                to="/"
                className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-slate-700"
              >
                Back to directory
              </Link>
            </div>
          </div>

          <div className="mt-6">
            <div className="grid grid-cols-2 gap-3 sm:grid-cols-4 lg:grid-cols-7">
              <div>
                <label htmlFor="filter-component" className="block text-xs font-semibold text-slate-500">
                  Component
                </label>
                <select
                  id="filter-component"
                  value={componentParam}
                  onChange={(changeEvent) => setFilterParam('component', changeEvent.target.value)}
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none focus:border-slate-500"
                >
                  <option value="">All</option>
                  {visibleComponentOptions.map((option) => (
                    <option key={option.value} value={option.value}>{option.label}</option>
                  ))}
                </select>
              </div>

              <div>
                <label htmlFor="filter-status" className="block text-xs font-semibold text-slate-500">
                  Status
                </label>
                <select
                  id="filter-status"
                  value={statusParam}
                  onChange={(changeEvent) => setFilterParam('status', changeEvent.target.value)}
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none focus:border-slate-500"
                >
                  <option value="">All</option>
                  {visibleStatusOptions.map((option) => (
                    <option key={option.value} value={option.value}>{option.label}</option>
                  ))}
                </select>
              </div>

              <div>
                <label htmlFor="filter-grade" className="block text-xs font-semibold text-slate-500">
                  Grade
                </label>
                <select
                  id="filter-grade"
                  value={gradeParam}
                  onChange={(changeEvent) => setFilterParam('grade', changeEvent.target.value)}
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none focus:border-slate-500"
                >
                  <option value="">All</option>
                  {visibleOfficerGradeOptions.length > 0 ? (
                    <optgroup label="Officer">
                      {visibleOfficerGradeOptions.map((option) => (
                        <option key={option.value} value={option.value}>{option.label}</option>
                      ))}
                    </optgroup>
                  ) : null}
                  {visibleWarrantOfficerGradeOptions.length > 0 ? (
                    <optgroup label="Warrant Officer">
                      {visibleWarrantOfficerGradeOptions.map((option) => (
                        <option key={option.value} value={option.value}>{option.label}</option>
                      ))}
                    </optgroup>
                  ) : null}
                  {visibleEnlistedGradeOptions.length > 0 ? (
                    <optgroup label="Enlisted">
                      {visibleEnlistedGradeOptions.map((option) => (
                        <option key={option.value} value={option.value}>{option.label}</option>
                      ))}
                    </optgroup>
                  ) : null}
                </select>
              </div>

              <div>
                <label htmlFor="filter-branch" className="block text-xs font-semibold text-slate-500">
                  Branch
                </label>
                <select
                  id="filter-branch"
                  value={branchParam}
                  onChange={(changeEvent) => setFilterParam('branch', changeEvent.target.value)}
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none focus:border-slate-500"
                >
                  <option value="">All</option>
                  {visibleBranchOptions.map((option) => (
                    <option key={option.value} value={option.value}>{option.label}</option>
                  ))}
                </select>
              </div>

              <div>
                <label htmlFor="filter-mos" className="block text-xs font-semibold text-slate-500">
                  MOS
                </label>
                <select
                  id="filter-mos"
                  value={mosParam}
                  onChange={(changeEvent) => setFilterParam('mos', changeEvent.target.value)}
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none focus:border-slate-500"
                >
                  <option value="">All</option>
                  {visibleMosOptions.map((option) => (
                    <option key={option.value} value={option.value}>{option.label}</option>
                  ))}
                </select>
              </div>

              <div>
                <label htmlFor="filter-aoc" className="block text-xs font-semibold text-slate-500">
                  AOC
                </label>
                <select
                  id="filter-aoc"
                  value={aocParam}
                  onChange={(changeEvent) => setFilterParam('aoc', changeEvent.target.value)}
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none focus:border-slate-500"
                >
                  <option value="">All</option>
                  {visibleAocOptions.map((option) => (
                    <option key={option.value} value={option.value}>{option.label}</option>
                  ))}
                </select>
              </div>

              <div>
                <label htmlFor="filter-state" className="block text-xs font-semibold text-slate-500">
                  State
                </label>
                <select
                  id="filter-state"
                  value={stateParam}
                  onChange={(changeEvent) => setFilterParam('state', changeEvent.target.value)}
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none focus:border-slate-500"
                >
                  <option value="">All</option>

                  <optgroup label="OCONUS">
                    {visiblePinnedOconusStateOptions.map((option) => (
                      <option key={option.value} value={option.value}>{option.label}</option>
                    ))}
                  </optgroup>

                  {visibleConusStateOptions.length > 0 ? (
                    <optgroup label="CONUS">
                      {visibleConusStateOptions.map((option) => (
                        <option key={option.value} value={option.value}>{option.label}</option>
                      ))}
                    </optgroup>
                  ) : null}

                  {visibleAdditionalStateOptions.length > 0 ? (
                    <optgroup label="Additional">
                      {visibleAdditionalStateOptions.map((option) => (
                        <option key={option.value} value={option.value}>{option.label}</option>
                      ))}
                    </optgroup>
                  ) : null}
                </select>
              </div>
            </div>

            {hasActiveFilters ? (
              <div className="mt-4">
                <button
                  type="button"
                  onClick={handleClearFilters}
                  className="inline-flex items-center justify-center rounded-xl bg-slate-100 px-5 py-2.5 text-sm font-semibold text-slate-600 transition hover:bg-slate-200"
                >
                  Clear all
                </button>
              </div>
            ) : null}
          </div>

          {errorMessage !== '' ? (
            <div className="mt-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              {errorMessage}
            </div>
          ) : null}
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <h2 className="text-lg font-semibold text-slate-900">Positions</h2>
              <span className="text-sm text-slate-500">{resultCount} returned</span>
            </div>

            {!isLoading && results.length > 0 ? (
              <button
                type="button"
                onClick={handleExportCSV}
                className="inline-flex items-center justify-center gap-1.5 rounded-xl bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-700 transition hover:bg-slate-200"
              >
                <svg className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path d="M10.75 2.75a.75.75 0 00-1.5 0v8.614L6.295 8.235a.75.75 0 10-1.09 1.03l4.25 4.5a.75.75 0 001.09 0l4.25-4.5a.75.75 0 00-1.09-1.03l-2.955 3.129V2.75z" />
                  <path d="M3.5 12.75a.75.75 0 00-1.5 0v2.5A2.75 2.75 0 004.75 18h10.5A2.75 2.75 0 0018 15.25v-2.5a.75.75 0 00-1.5 0v2.5c0 .69-.56 1.25-1.25 1.25H4.75c-.69 0-1.25-.56-1.25-1.25v-2.5z" />
                </svg>
                Export CSV
              </button>
            ) : null}
          </div>

          {isLoading ? (
            <div className="mt-4 rounded-xl border border-slate-200 bg-slate-50 px-4 py-6 text-sm text-slate-500">
              Loading positions...
            </div>
          ) : null}

          {!isLoading && results.length === 0 && errorMessage === '' ? (
            <div className="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-sm text-slate-500">
              {hasActiveFilters
                ? 'No positions match the current filters.'
                : 'No positions found.'}
            </div>
          ) : null}

          {!isLoading && results.length > 0 ? (
            <div className="mt-4 overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead>
                  <tr className="border-b border-slate-200 text-xs font-semibold uppercase tracking-wider text-slate-500">
                    <th className="px-3 py-3">Position</th>
                    <th className="px-3 py-3">Grade / Specialty</th>
                    <th className="px-3 py-3">Component</th>
                    <th className="px-3 py-3">Organization / Section</th>
                    <th className="px-3 py-3">Location</th>
                    <th className="px-3 py-3">Status</th>
                    <th className="px-3 py-3">Occupant</th>
                  </tr>
                </thead>

                <tbody>
                  {results.map((positionResult) => (
                    <tr
                      key={positionResult.billet_id}
                      className="border-b border-slate-100 hover:bg-slate-50"
                    >
                      <td className="px-3 py-3">
                        <div className="font-medium text-slate-900">
                          {positionResult.billet_title}
                        </div>

                        {positionResult.position_number !== '' ? (
                          <div className="text-xs text-slate-500">
                            Position {positionResult.position_number}
                          </div>
                        ) : null}

                        <div className="text-xs text-slate-500">
                          UIC {positionResult.uic || '—'}
                          {' · '}
                          Paragraph/Line {positionResult.paragraph_number || '—'}/{positionResult.line_number || '—'}
                        </div>
                      </td>

                      <td className="px-3 py-3 text-slate-600">
                        <div className="font-medium text-slate-900">
                          {positionResult.grade_code || '—'}
                        </div>
                        <div className="text-xs text-slate-500">
                          {[positionResult.branch_code, positionResult.mos_code, positionResult.aoc_code]
                            .filter((code) => code !== '')
                            .join(' / ') || '—'}
                        </div>
                      </td>

                      <td className="px-3 py-3 text-slate-600">
                        {positionResult.component || '—'}
                      </td>

                      <td className="px-3 py-3 text-slate-600">
                        <div className="font-medium text-slate-900">
                          {positionResult.organization_short_name || positionResult.organization_name || '—'}
                        </div>

                        {positionResult.section_id !== 0 ? (
                          <Link
                            to={`/sections/${positionResult.section_id}`}
                            className="text-xs hover:text-blue-700 hover:underline"
                          >
                            {positionResult.section_display_name}
                          </Link>
                        ) : (
                          <div className="text-xs text-slate-400">—</div>
                        )}
                      </td>

                      <td className="px-3 py-3 text-slate-600">
                        {positionResult.duty_location !== '' ? (
                          <>
                            {positionResult.duty_location}
                            {positionResult.state_code !== '' ? `, ${positionResult.state_code}` : ''}
                          </>
                        ) : (
                          '—'
                        )}
                      </td>

                      <td className="px-3 py-3">
                        {renderStatusBadge(positionResult.status)}
                      </td>

                      <td className="px-3 py-3">
                        {positionResult.primary_person_id !== 0 ? (
                          <Link
                            to={`/people/${positionResult.primary_person_id}`}
                            className="text-slate-700 hover:text-blue-700 hover:underline"
                          >
                            {positionResult.primary_person_rank !== '' ? `${positionResult.primary_person_rank} ` : ''}
                            {positionResult.primary_person_display_name}
                          </Link>
                        ) : (
                          <span className="text-slate-400">—</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : null}
        </section>
      </div>
    </main>
  )
}

export default ExplorerPage