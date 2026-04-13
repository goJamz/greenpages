import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import { Link, useSearchParams } from 'react-router'
import {
  getExplorerPositions,
  type ExplorerPositionFilters,
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
    <span className={`inline-flex rounded-full px-3 py-1 text-xs font-semibold ${badgeClasses}`}>
      {status}
    </span>
  )
}

function ExplorerPage() {
  const [searchParams, setSearchParams] = useSearchParams()

  const [componentInput, setComponentInput] = useState(searchParams.get('component') || '')
  const [gradeInput, setGradeInput] = useState(searchParams.get('grade') || '')
  const [organizationInput, setOrganizationInput] = useState(searchParams.get('organization') || '')
  const [statusInput, setStatusInput] = useState(searchParams.get('status') || '')
  const [results, setResults] = useState<ExplorerPositionResult[]>([])
  const [appliedFilters, setAppliedFilters] = useState<ExplorerPositionFilters>({
    component: '',
    grade: '',
    branch: '',
    mos: '',
    aoc: '',
    state: '',
    status: '',
    organization: '',
  })
  const [isLoading, setIsLoading] = useState(true)
  const [errorMessage, setErrorMessage] = useState('')

  useEffect(() => {
    setComponentInput(searchParams.get('component') || '')
    setGradeInput(searchParams.get('grade') || '')
    setOrganizationInput(searchParams.get('organization') || '')
    setStatusInput(searchParams.get('status') || '')
  }, [searchParams])

  useEffect(() => {
    let isCancelled = false

    async function loadExplorerPositions() {
      const filters = {
        component: searchParams.get('component') || '',
        grade: searchParams.get('grade') || '',
        organization: searchParams.get('organization') || '',
        status: searchParams.get('status') || '',
      }

      if (!isCancelled) {
        setIsLoading(true)
        setErrorMessage('')
      }

      try {
        const explorerResponse = await getExplorerPositions(filters, 100, 0)

        if (!isCancelled) {
          setAppliedFilters(explorerResponse.filters)
          setResults(explorerResponse.results)
        }
      } catch (explorerError) {
        if (!isCancelled) {
          setResults([])

          if (explorerError instanceof Error) {
            setErrorMessage(explorerError.message)
          } else {
            setErrorMessage('Failed to load explorer positions')
          }
        }
      } finally {
        if (!isCancelled) {
          setIsLoading(false)
        }
      }
    }

    loadExplorerPositions()

    return () => {
      isCancelled = true
    }
  }, [searchParams])

  function handleFilterSubmit(formEvent: FormEvent<HTMLFormElement>) {
    const nextSearchParams = new URLSearchParams()

    formEvent.preventDefault()

    if (componentInput.trim() !== '') {
      nextSearchParams.set('component', componentInput.trim())
    }

    if (gradeInput.trim() !== '') {
      nextSearchParams.set('grade', gradeInput.trim())
    }

    if (organizationInput.trim() !== '') {
      nextSearchParams.set('organization', organizationInput.trim())
    }

    if (statusInput.trim() !== '') {
      nextSearchParams.set('status', statusInput.trim())
    }

    setSearchParams(nextSearchParams)
  }

  function handleClearFilters() {
    setSearchParams({})
  }

  const hasAppliedFilters =
    appliedFilters.component !== '' ||
    appliedFilters.grade !== '' ||
    appliedFilters.organization !== '' ||
    appliedFilters.status !== ''

  return (
    <main className="min-h-screen bg-slate-100 text-slate-900">
      <div className="mx-auto flex max-w-6xl flex-col gap-6 px-4 py-10 sm:px-6 lg:px-8">
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
                Browse billets across the force with filters. This is the explorer experience,
                not a keyword search page.
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

          <form className="mt-6 grid gap-3 sm:grid-cols-2 lg:grid-cols-5" onSubmit={handleFilterSubmit}>
            <div className="flex flex-col gap-2">
              <label htmlFor="explorer-component" className="text-sm font-medium text-slate-700">
                Component
              </label>
              <input
                id="explorer-component"
                type="text"
                value={componentInput}
                onChange={(changeEvent) => setComponentInput(changeEvent.target.value)}
                placeholder="Active"
                className="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-slate-500"
              />
            </div>

            <div className="flex flex-col gap-2">
              <label htmlFor="explorer-grade" className="text-sm font-medium text-slate-700">
                Grade
              </label>
              <input
                id="explorer-grade"
                type="text"
                value={gradeInput}
                onChange={(changeEvent) => setGradeInput(changeEvent.target.value)}
                placeholder="MAJ"
                className="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-slate-500"
              />
            </div>

            <div className="flex flex-col gap-2">
              <label htmlFor="explorer-organization" className="text-sm font-medium text-slate-700">
                Organization
              </label>
              <input
                id="explorer-organization"
                type="text"
                value={organizationInput}
                onChange={(changeEvent) => setOrganizationInput(changeEvent.target.value)}
                placeholder="NETCOM"
                className="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-slate-500"
              />
            </div>

            <div className="flex flex-col gap-2">
              <label htmlFor="explorer-status" className="text-sm font-medium text-slate-700">
                Status
              </label>
              <select
                id="explorer-status"
                value={statusInput}
                onChange={(changeEvent) => setStatusInput(changeEvent.target.value)}
                className="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none focus:border-slate-500"
              >
                <option value="">All</option>
                <option value="filled">Filled</option>
                <option value="vacant">Vacant</option>
                <option value="unknown">Unknown</option>
              </select>
            </div>

            <div className="flex items-end gap-3">
              <button
                type="submit"
                disabled={isLoading}
                className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-700 disabled:cursor-not-allowed disabled:bg-slate-400"
              >
                {isLoading ? 'Loading...' : 'Apply filters'}
              </button>

              <button
                type="button"
                onClick={handleClearFilters}
                className="inline-flex items-center justify-center rounded-xl border border-slate-300 bg-white px-5 py-3 text-sm font-semibold text-slate-700 transition hover:bg-slate-50"
              >
                Clear
              </button>
            </div>
          </form>

          {errorMessage !== '' ? (
            <div className="mt-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              {errorMessage}
            </div>
          ) : null}

          <div className="mt-4 text-sm text-slate-600">
            {hasAppliedFilters ? (
              <>
                Filtered positions: <span className="font-semibold text-slate-900">{results.length}</span>
              </>
            ) : (
              <>
                Showing first <span className="font-semibold text-slate-900">{results.length}</span> positions
              </>
            )}
          </div>
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between gap-4">
            <h2 className="text-lg font-semibold text-slate-900">Positions</h2>
            <span className="text-sm text-slate-500">{results.length} results</span>
          </div>

          {!isLoading && results.length === 0 && errorMessage === '' ? (
            <div className="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-sm text-slate-500">
              No positions matched the current filters.
            </div>
          ) : null}

          {results.length > 0 ? (
            <div className="mt-4 grid gap-4">
              {results.map((positionResult) => (
                <article
                  key={positionResult.billet_id}
                  className="rounded-2xl border border-slate-200 bg-slate-50 p-4"
                >
                  <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                    <div className="min-w-0">
                      <p className="text-xs font-semibold uppercase tracking-[0.16em] text-slate-500">
                        {positionResult.organization_name}
                      </p>

                      <h3 className="mt-1 text-lg font-semibold text-slate-900">
                        {positionResult.billet_title}
                      </h3>

                      <p className="mt-2 text-sm text-slate-600">
                        {positionResult.section_display_name}
                      </p>

                      <p className="mt-1 text-sm text-slate-500">
                        Grade {positionResult.grade_code || 'N/A'}
                        {' · '}
                        Branch {positionResult.branch_code || 'N/A'}
                        {' · '}
                        MOS {positionResult.mos_code || 'N/A'}
                        {' · '}
                        AOC {positionResult.aoc_code || 'N/A'}
                      </p>

                      <p className="mt-1 text-sm text-slate-500">
                        Component {positionResult.component || 'N/A'}
                        {' · '}
                        UIC {positionResult.uic || 'N/A'}
                        {' · '}
                        Paragraph/Line {positionResult.paragraph_number || 'N/A'}/{positionResult.line_number || 'N/A'}
                      </p>

                      <p className="mt-1 text-sm text-slate-500">
                        {positionResult.duty_location || 'N/A'}
                        {positionResult.state_code !== '' ? `, ${positionResult.state_code}` : ''}
                      </p>

                      {positionResult.primary_person_id !== 0 ? (
                        <p className="mt-3 text-sm text-slate-600">
                          Primary occupant:{' '}
                          <Link
                            to={`/people/${positionResult.primary_person_id}`}
                            className="font-medium text-slate-900 hover:text-blue-700 hover:underline"
                          >
                            {positionResult.primary_person_rank !== ''
                              ? `${positionResult.primary_person_rank} `
                              : ''}
                            {positionResult.primary_person_display_name}
                          </Link>
                        </p>
                      ) : (
                        <p className="mt-3 text-sm text-slate-500">No primary occupant listed.</p>
                      )}
                    </div>

                    <div className="flex shrink-0 flex-col items-start gap-3 sm:items-end">
                      {renderStatusBadge(positionResult.status)}

                      <Link
                        to={`/sections/${positionResult.section_id}`}
                        className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-slate-700"
                      >
                        Open section
                      </Link>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          ) : null}
        </section>
      </div>
    </main>
  )
}

export default ExplorerPage