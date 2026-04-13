import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import { Link, useLocation, useSearchParams } from 'react-router'
import {
  searchPeople,
  searchSections,
  type PersonSearchResult,
  type SectionSearchResult,
} from '../api/greenpages'

type SearchType = 'sections' | 'people'

function isValidSearchType(value: string): value is SearchType {
  return value === 'sections' || value === 'people'
}

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

function SearchPage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const location = useLocation()

  const queryParam = searchParams.get('q') || ''
  const searchTypeParam = searchParams.get('mode') || searchParams.get('type') || 'sections'
  const activeSearchType: SearchType = isValidSearchType(searchTypeParam)
    ? searchTypeParam
    : 'sections'
  const currentSearch = location.search

  const [searchInput, setSearchInput] = useState(queryParam)
  const [submittedQuery, setSubmittedQuery] = useState('')
  const [sectionResults, setSectionResults] = useState<SectionSearchResult[]>([])
  const [personResults, setPersonResults] = useState<PersonSearchResult[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [errorMessage, setErrorMessage] = useState('')

  const resultCount = activeSearchType === 'people' ? personResults.length : sectionResults.length

  useEffect(() => {
    setSearchInput(queryParam)
  }, [queryParam])

  useEffect(() => {
    let isCancelled = false

    async function loadResults() {
      if (queryParam === '') {
        if (!isCancelled) {
          setSubmittedQuery('')
          setSectionResults([])
          setPersonResults([])
          setErrorMessage('')
          setIsLoading(false)
        }
        return
      }

      if (!isCancelled) {
        setIsLoading(true)
        setErrorMessage('')
      }

      try {
        if (activeSearchType === 'people') {
          const peopleResponse = await searchPeople(queryParam)

          if (!isCancelled) {
            setSubmittedQuery(peopleResponse.query)
            setPersonResults(peopleResponse.results)
            setSectionResults([])
          }
        } else {
          const sectionResponse = await searchSections(queryParam)

          if (!isCancelled) {
            setSubmittedQuery(sectionResponse.query)
            setSectionResults(sectionResponse.results)
            setPersonResults([])
          }
        }
      } catch (searchError) {
        if (!isCancelled) {
          setSubmittedQuery(queryParam)
          setSectionResults([])
          setPersonResults([])

          if (searchError instanceof Error) {
            setErrorMessage(searchError.message)
          } else {
            setErrorMessage('Search failed')
          }
        }
      } finally {
        if (!isCancelled) {
          setIsLoading(false)
        }
      }
    }

    loadResults()

    return () => {
      isCancelled = true
    }
  }, [queryParam, activeSearchType])

  function handleSearchSubmit(formEvent: FormEvent<HTMLFormElement>) {
    let trimmedSearchInput: string // Search input with surrounding whitespace removed.

    formEvent.preventDefault()

    trimmedSearchInput = searchInput.trim()

    if (trimmedSearchInput === '') {
      setSubmittedQuery('')
      setSectionResults([])
      setPersonResults([])
      setIsLoading(false)
      setErrorMessage(
        activeSearchType === 'people'
          ? 'Enter a person search like "Johnson" or "Michael Johnson".'
          : 'Enter a section search like "XVIII Airborne Corps G6" or "NETCOM G6".',
      )
      setSearchParams({})
      return
    }

    setSearchParams({
      q: trimmedSearchInput,
      mode: activeSearchType,
    })
  }

  function handleSearchTypeChange(newType: SearchType) {
    if (newType === activeSearchType) {
      return
    }

    setErrorMessage('')

    if (queryParam !== '') {
      setSearchParams({
        q: queryParam,
        mode: newType,
      })
      return
    }

    setSearchParams({
      mode: newType,
    })
  }

  return (
    <main className="min-h-screen bg-slate-100 text-slate-900">
      <div className="mx-auto flex max-w-5xl flex-col gap-6 px-4 py-10 sm:px-6 lg:px-8">
        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">
                Green Pages
              </p>

              <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-900">
                Directory search
              </h1>

              <p className="mt-3 max-w-3xl text-sm leading-6 text-slate-600">
                Search for sections or people across the directory.
              </p>
            </div>

            <div className="shrink-0">
              <Link
                to="/explorer"
                className="inline-flex items-center justify-center rounded-xl border border-slate-300 bg-white px-4 py-2 text-sm font-semibold text-slate-700 transition hover:bg-slate-50"
              >
                Open explorer
              </Link>
            </div>
          </div>

          <div className="mt-6 inline-flex rounded-xl border border-slate-200 bg-slate-50 p-1">
            <button
              type="button"
              onClick={() => handleSearchTypeChange('sections')}
              className={`rounded-lg px-4 py-2 text-sm font-semibold transition ${
                activeSearchType === 'sections'
                  ? 'bg-slate-900 text-white'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              Sections
            </button>

            <button
              type="button"
              onClick={() => handleSearchTypeChange('people')}
              className={`rounded-lg px-4 py-2 text-sm font-semibold transition ${
                activeSearchType === 'people'
                  ? 'bg-slate-900 text-white'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              People
            </button>
          </div>

          <form className="mt-6 flex flex-col gap-3 sm:flex-row" onSubmit={handleSearchSubmit}>
            <label className="sr-only" htmlFor="directory-search">
              Search {activeSearchType}
            </label>

            <input
              id="directory-search"
              type="text"
              value={searchInput}
              onChange={(changeEvent) => setSearchInput(changeEvent.target.value)}
              placeholder={
                activeSearchType === 'people'
                  ? 'Try: Johnson or AFNC-G6'
                  : 'Try: XVIII Airborne Corps G6'
              }
              className="w-full rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-slate-500"
            />

            <button
              type="submit"
              disabled={isLoading}
              className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-700 disabled:cursor-not-allowed disabled:bg-slate-400"
            >
              {isLoading ? 'Searching...' : 'Search'}
            </button>
          </form>

          {errorMessage !== '' ? (
            <div className="mt-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              {errorMessage}
            </div>
          ) : null}

          {submittedQuery !== '' && errorMessage === '' ? (
            <div className="mt-4 text-sm text-slate-600">
              Results for <span className="font-semibold text-slate-900">{submittedQuery}</span>
              : {` ${resultCount}`}
            </div>
          ) : null}
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between gap-4">
            <h2 className="text-lg font-semibold text-slate-900">Matches</h2>
            <span className="text-sm text-slate-500">{resultCount} results</span>
          </div>

          {submittedQuery !== '' && !isLoading && resultCount === 0 && errorMessage === '' ? (
            <div className="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-sm text-slate-500">
              No {activeSearchType} found for "{submittedQuery}".
            </div>
          ) : null}

          {submittedQuery === '' && !isLoading ? (
            <div className="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-sm text-slate-500">
              No results yet. Run a search to see real data from the backend.
            </div>
          ) : null}

          {activeSearchType === 'sections' && sectionResults.length > 0 ? (
            <div className="mt-4 grid gap-4">
              {sectionResults.map((sectionResult) => (
                <article
                  key={sectionResult.section_id}
                  className="rounded-2xl border border-slate-200 bg-slate-50 p-4"
                >
                  <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                    <div className="min-w-0">
                      <p className="text-xs font-semibold uppercase tracking-[0.16em] text-slate-500">
                        {sectionResult.organization_name}
                      </p>

                      <h3 className="mt-1 text-lg font-semibold text-slate-900">
                        {sectionResult.display_name}
                      </h3>

                      <p className="mt-2 text-sm text-slate-600">
                        <span className="font-medium text-slate-800">
                          {sectionResult.section_code}
                        </span>
                        {' · '}
                        {sectionResult.section_name}
                      </p>

                      {sectionResult.organization_short_name !== '' ? (
                        <p className="mt-1 text-sm text-slate-500">
                          {sectionResult.organization_short_name}
                        </p>
                      ) : null}
                    </div>

                    <div className="flex shrink-0 flex-col items-start gap-3 sm:items-end">
                      <Link
                        to={{
                          pathname: `/sections/${sectionResult.section_id}`,
                          search: currentSearch,
                        }}
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

          {activeSearchType === 'people' && personResults.length > 0 ? (
            <div className="mt-4 grid gap-4">
              {personResults.map((personResult) => (
                <article
                  key={personResult.person_id}
                  className="rounded-2xl border border-slate-200 bg-slate-50 p-4"
                >
                  <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                    <div className="min-w-0">
                      <p className="text-xs font-semibold uppercase tracking-[0.16em] text-slate-500">
                        {personResult.organization_name !== '' ? personResult.organization_name : 'Unassigned'}
                      </p>

                      <h3 className="mt-1 text-lg font-semibold text-slate-900">
                        {personResult.rank !== '' ? `${personResult.rank} ` : ''}
                        {personResult.display_name}
                      </h3>

                      {personResult.billet_title !== '' ? (
                        <p className="mt-2 text-sm text-slate-600">
                          {personResult.billet_title}
                          {personResult.billet_grade_code !== ''
                            ? ` · Grade ${personResult.billet_grade_code}`
                            : ''}
                        </p>
                      ) : null}

                      {personResult.section_display_name !== '' || personResult.office_symbol !== '' ? (
                        <p className="mt-1 text-sm text-slate-500">
                          {personResult.section_display_name !== ''
                            ? personResult.section_display_name
                            : 'No current section'}
                          {personResult.office_symbol !== '' ? ` · ${personResult.office_symbol}` : ''}
                        </p>
                      ) : null}

                      {personResult.organization_short_name !== '' ? (
                        <p className="mt-1 text-sm text-slate-500">
                          {personResult.organization_short_name}
                        </p>
                      ) : null}

                      {personResult.work_email !== '' ? (
                        <p className="mt-1 text-sm text-slate-500">
                          {personResult.work_email}
                        </p>
                      ) : null}

                      {personResult.work_phone !== '' ? (
                        <p className="mt-1 text-sm text-slate-500">
                          {personResult.work_phone}
                        </p>
                      ) : null}
                    </div>

                    <div className="flex shrink-0 flex-col items-start gap-3 sm:items-end">
                      {personResult.billet_id !== 0 ? renderStatusBadge(personResult.billet_status) : null}

                      <Link
                        to={{
                          pathname: `/people/${personResult.person_id}`,
                          search: currentSearch,
                        }}
                        className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-slate-700"
                      >
                        View person
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

export default SearchPage