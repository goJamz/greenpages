import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import { Link, useSearchParams } from 'react-router'
import {
  getExplorerPositions,
  getExplorerPositionsExportURL,
  type ExplorerPositionResult,
} from '../api/greenpages'

function renderStatusBadge(status: string) {
  let badgeClasses: string // Tailwind classes used to color the badge.

  if (status === 'Filled') {
    badgeClasses = 'bg-emerald-100 text-emerald-700'
  } else if (status === 'Vacant') {
    badgeClasses = 'bg-amber-100 text-amber-700'
  } else {
    badgeClasses = 'bg-slate-200 text-slate-700'
  }

  return (
    <span className={`inline-flex rounded-full px-2 py-0.5 text-xs font-semibold ${badgeClasses}`}>
      {status}
    </span>
  )
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
  const organizationParam = searchParams.get('organization') || ''

  const [componentInput, setComponentInput] = useState(componentParam)
  const [gradeInput, setGradeInput] = useState(gradeParam)
  const [branchInput, setBranchInput] = useState(branchParam)
  const [mosInput, setMosInput] = useState(mosParam)
  const [aocInput, setAocInput] = useState(aocParam)
  const [stateInput, setStateInput] = useState(stateParam)
  const [statusInput, setStatusInput] = useState(statusParam)
  const [organizationInput, setOrganizationInput] = useState(organizationParam)

  const [results, setResults] = useState<ExplorerPositionResult[]>([])
  const [resultCount, setResultCount] = useState(0)
  const [isLoading, setIsLoading] = useState(true)
  const [errorMessage, setErrorMessage] = useState('')

  useEffect(() => {
    setComponentInput(componentParam)
    setGradeInput(gradeParam)
    setBranchInput(branchParam)
    setMosInput(mosParam)
    setAocInput(aocParam)
    setStateInput(stateParam)
    setStatusInput(statusParam)
    setOrganizationInput(organizationParam)
  }, [
    componentParam,
    gradeParam,
    branchParam,
    mosParam,
    aocParam,
    stateParam,
    statusParam,
    organizationParam,
  ])

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
            organization: organizationParam,
          },
          100,
          0,
        )

        if (!isCancelled) {
          setResults(explorerResponse.results)
          setResultCount(explorerResponse.count)
        }
      } catch (fetchError) {
        if (!isCancelled) {
          setResults([])
          setResultCount(0)

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
    organizationParam,
  ])

  function handleFilterSubmit(formEvent: FormEvent<HTMLFormElement>) {
    let nextSearchParams: URLSearchParams // New URL search params built from current filter inputs.

    formEvent.preventDefault()

    nextSearchParams = new URLSearchParams()

    if (componentInput.trim() !== '') {
      nextSearchParams.set('component', componentInput.trim())
    }

    if (gradeInput.trim() !== '') {
      nextSearchParams.set('grade', gradeInput.trim())
    }

    if (branchInput.trim() !== '') {
      nextSearchParams.set('branch', branchInput.trim())
    }

    if (mosInput.trim() !== '') {
      nextSearchParams.set('mos', mosInput.trim())
    }

    if (aocInput.trim() !== '') {
      nextSearchParams.set('aoc', aocInput.trim())
    }

    if (stateInput.trim() !== '') {
      nextSearchParams.set('state', stateInput.trim())
    }

    if (statusInput.trim() !== '') {
      nextSearchParams.set('status', statusInput.trim())
    }

    if (organizationInput.trim() !== '') {
      nextSearchParams.set('organization', organizationInput.trim())
    }

    setSearchParams(nextSearchParams)
  }

  function handleClearFilters() {
    setSearchParams({})
  }

  const hasActiveFilters =
    componentParam !== '' ||
    gradeParam !== '' ||
    branchParam !== '' ||
    mosParam !== '' ||
    aocParam !== '' ||
    stateParam !== '' ||
    statusParam !== '' ||
    organizationParam !== ''

  const exportURL = getExplorerPositionsExportURL({
    component: componentParam,
    grade: gradeParam,
    branch: branchParam,
    mos: mosParam,
    aoc: aocParam,
    state: stateParam,
    status: statusParam,
    organization: organizationParam,
  })

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
                branch, MOS, AOC, state, status, or organization.
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

          <form className="mt-6" onSubmit={handleFilterSubmit}>
            <div className="grid grid-cols-2 gap-3 sm:grid-cols-4 lg:grid-cols-8">
              <div>
                <label htmlFor="filter-component" className="block text-xs font-semibold text-slate-500">
                  Component
                </label>
                <select
                  id="filter-component"
                  value={componentInput}
                  onChange={(changeEvent) => setComponentInput(changeEvent.target.value)}
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none focus:border-slate-500"
                >
                  <option value="">All</option>
                  <option value="Active">Active</option>
                  <option value="Guard">Guard</option>
                  <option value="Reserve">Reserve</option>
                </select>
              </div>

              <div>
                <label htmlFor="filter-status" className="block text-xs font-semibold text-slate-500">
                  Status
                </label>
                <select
                  id="filter-status"
                  value={statusInput}
                  onChange={(changeEvent) => setStatusInput(changeEvent.target.value)}
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none focus:border-slate-500"
                >
                  <option value="">All</option>
                  <option value="filled">Filled</option>
                  <option value="vacant">Vacant</option>
                  <option value="unknown">Unknown</option>
                </select>
              </div>

              <div>
                <label htmlFor="filter-grade" className="block text-xs font-semibold text-slate-500">
                  Grade
                </label>
                <input
                  id="filter-grade"
                  type="text"
                  value={gradeInput}
                  onChange={(changeEvent) => setGradeInput(changeEvent.target.value)}
                  placeholder="e.g. COL"
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-slate-500"
                />
              </div>

              <div>
                <label htmlFor="filter-branch" className="block text-xs font-semibold text-slate-500">
                  Branch
                </label>
                <input
                  id="filter-branch"
                  type="text"
                  value={branchInput}
                  onChange={(changeEvent) => setBranchInput(changeEvent.target.value)}
                  placeholder="e.g. SC"
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-slate-500"
                />
              </div>

              <div>
                <label htmlFor="filter-mos" className="block text-xs font-semibold text-slate-500">
                  MOS
                </label>
                <input
                  id="filter-mos"
                  type="text"
                  value={mosInput}
                  onChange={(changeEvent) => setMosInput(changeEvent.target.value)}
                  placeholder="e.g. 25B"
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-slate-500"
                />
              </div>

              <div>
                <label htmlFor="filter-aoc" className="block text-xs font-semibold text-slate-500">
                  AOC
                </label>
                <input
                  id="filter-aoc"
                  type="text"
                  value={aocInput}
                  onChange={(changeEvent) => setAocInput(changeEvent.target.value)}
                  placeholder="e.g. 25A"
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-slate-500"
                />
              </div>

              <div>
                <label htmlFor="filter-state" className="block text-xs font-semibold text-slate-500">
                  State
                </label>
                <input
                  id="filter-state"
                  type="text"
                  value={stateInput}
                  onChange={(changeEvent) => setStateInput(changeEvent.target.value)}
                  placeholder="e.g. NC"
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-slate-500"
                />
              </div>

              <div>
                <label htmlFor="filter-organization" className="block text-xs font-semibold text-slate-500">
                  Organization
                </label>
                <input
                  id="filter-organization"
                  type="text"
                  value={organizationInput}
                  onChange={(changeEvent) => setOrganizationInput(changeEvent.target.value)}
                  placeholder="e.g. NETCOM"
                  className="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-slate-500"
                />
              </div>
            </div>

            <div className="mt-4 flex flex-wrap gap-3">
              <button
                type="submit"
                disabled={isLoading}
                className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-slate-700 disabled:cursor-not-allowed disabled:bg-slate-400"
              >
                {isLoading ? 'Loading...' : 'Apply filters'}
              </button>

              {hasActiveFilters ? (
                <button
                  type="button"
                  onClick={handleClearFilters}
                  className="inline-flex items-center justify-center rounded-xl bg-slate-100 px-5 py-2.5 text-sm font-semibold text-slate-600 transition hover:bg-slate-200"
                >
                  Clear all
                </button>
              ) : null}

              <a
                href={exportURL}
                className="inline-flex items-center justify-center rounded-xl border border-slate-300 bg-white px-5 py-2.5 text-sm font-semibold text-slate-700 transition hover:bg-slate-50"
              >
                Export CSV
              </a>
            </div>
          </form>

          {errorMessage !== '' ? (
            <div className="mt-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              {errorMessage}
            </div>
          ) : null}
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between gap-4">
            <h2 className="text-lg font-semibold text-slate-900">Positions</h2>
            <span className="text-sm text-slate-500">{resultCount} returned</span>
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