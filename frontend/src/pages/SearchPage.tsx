import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import { Link, useLocation, useSearchParams } from 'react-router'
import { searchSections, type SectionSearchResult } from '../api/greenpages'

function SearchPage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const location = useLocation()

  const queryParam = searchParams.get('q') || ''
  const currentSearch = location.search

  const [searchInput, setSearchInput] = useState(queryParam)
  const [submittedQuery, setSubmittedQuery] = useState('')
  const [sectionResults, setSectionResults] = useState<SectionSearchResult[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [errorMessage, setErrorMessage] = useState('')

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
          setIsLoading(false)
        }
        return
      }

      if (!isCancelled) {
        setIsLoading(true)
        setErrorMessage('')
      }

      try {
        const searchResponse = await searchSections(queryParam)

        if (!isCancelled) {
          setSubmittedQuery(searchResponse.query)
          setSectionResults(searchResponse.results)
        }
      } catch (searchError) {
        if (!isCancelled) {
          setSubmittedQuery(queryParam)
          setSectionResults([])

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
  }, [queryParam])

  function handleSearchSubmit(formEvent: FormEvent<HTMLFormElement>) {
    let trimmedSearchInput: string // Search input with surrounding whitespace removed.

    formEvent.preventDefault()

    trimmedSearchInput = searchInput.trim()

    if (trimmedSearchInput === '') {
      setSubmittedQuery('')
      setSectionResults([])
      setIsLoading(false)
      setErrorMessage('Enter a section search like "XVIII Airborne Corps G6" or "NETCOM G6".')
      setSearchParams({})
      return
    }

    setSearchParams({ q: trimmedSearchInput })
  }

  return (
    <main className="min-h-screen bg-slate-100 text-slate-900">
      <div className="mx-auto flex max-w-5xl flex-col gap-6 px-4 py-10 sm:px-6 lg:px-8">
        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">
            Green Pages
          </p>

          <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-900">
            Section search
          </h1>

          <p className="mt-3 max-w-3xl text-sm leading-6 text-slate-600">
            Search for a section and open the whole shop. This is the first real product loop
            for the frontend.
          </p>

          <form className="mt-6 flex flex-col gap-3 sm:flex-row" onSubmit={handleSearchSubmit}>
            <label className="sr-only" htmlFor="section-search">
              Search sections
            </label>

            <input
              id="section-search"
              type="text"
              value={searchInput}
              onChange={(changeEvent) => setSearchInput(changeEvent.target.value)}
              placeholder="Try: XVIII Airborne Corps G6"
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
              : {` ${sectionResults.length}`}
            </div>
          ) : null}
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between gap-4">
            <h2 className="text-lg font-semibold text-slate-900">Matches</h2>
            <span className="text-sm text-slate-500">{sectionResults.length} results</span>
          </div>

          {submittedQuery !== '' && !isLoading && sectionResults.length === 0 && errorMessage === '' ? (
            <div className="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-sm text-slate-500">
              No sections found for "{submittedQuery}".
            </div>
          ) : null}

          {submittedQuery === '' && !isLoading ? (
            <div className="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-sm text-slate-500">
              No results yet. Run a section search to see real data from the backend.
            </div>
          ) : null}

          {sectionResults.length > 0 ? (
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
                      <span className="inline-flex rounded-full bg-slate-200 px-3 py-1 text-xs font-semibold text-slate-700">
                        Section ID {sectionResult.section_id}
                      </span>

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
        </section>
      </div>
    </main>
  )
}

export default SearchPage