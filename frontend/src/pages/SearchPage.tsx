import { useState } from 'react'
import { Link } from 'react-router'
import { searchSections } from '../api/greenpages'
import type { SectionSearchResult } from '../api/greenpages'

function SearchPage() {
  let searchInputValue = useState('')                          // Current text entered in the search input.
  let submittedQueryValue = useState('')                       // Last submitted query shown above the results.
  let sectionResultsValue = useState<SectionSearchResult[]>([]) // Section results returned by the backend.
  let isLoadingValue = useState(false)                        // Whether the search request is currently in flight.
  let errorMessageValue = useState('')                        // User-visible validation or request error message.

  let searchInput = searchInputValue[0]
  let setSearchInput = searchInputValue[1]

  let submittedQuery = submittedQueryValue[0]
  let setSubmittedQuery = submittedQueryValue[1]

  let sectionResults = sectionResultsValue[0]
  let setSectionResults = sectionResultsValue[1]

  let isLoading = isLoadingValue[0]
  let setIsLoading = isLoadingValue[1]

  let errorMessage = errorMessageValue[0]
  let setErrorMessage = errorMessageValue[1]

  async function handleSearchSubmit(formEvent: React.FormEvent<HTMLFormElement>) {
    let trimmedSearchInput: string  // Search input with surrounding whitespace removed.
    let searchResponse              // Successful section search response from the backend.

    formEvent.preventDefault()

    trimmedSearchInput = searchInput.trim()

    if (trimmedSearchInput === '') {
      setSubmittedQuery('')
      setSectionResults([])
      setErrorMessage('Enter a section search like "XVIII Airborne Corps G6" or "NETCOM G6".')
      return
    }

    setIsLoading(true)
    setErrorMessage('')

    try {
      searchResponse = await searchSections(trimmedSearchInput)

      setSubmittedQuery(searchResponse.query)
      setSectionResults(searchResponse.results)
    } catch (searchError) {
      setSubmittedQuery(trimmedSearchInput)
      setSectionResults([])

      if (searchError instanceof Error) {
        setErrorMessage(searchError.message)
      } else {
        setErrorMessage('Search failed')
      }
    } finally {
      setIsLoading(false)
    }
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
            Search for a section and confirm the backend is returning useful section-first results.
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
              {`: ${sectionResults.length}`}
            </div>
          ) : null}
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between gap-4">
            <h2 className="text-lg font-semibold text-slate-900">Matches</h2>
            <span className="text-sm text-slate-500">{sectionResults.length} results</span>
          </div>

          {sectionResults.length === 0 ? (
            <div className="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-sm text-slate-500">
              No results yet. Run a section search to see real data from the backend.
            </div>
          ) : (
            <div className="mt-4 grid gap-4">
              {sectionResults.map((sectionResult) => (
                <Link
                  key={sectionResult.section_id}
                  to={`/sections/${sectionResult.section_id}`}
                  className="block rounded-2xl border border-slate-200 bg-slate-50 p-4 transition hover:border-slate-400 hover:bg-slate-100"
                >
                  <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
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

                    <div className="shrink-0">
                      <span className="inline-flex rounded-full bg-slate-200 px-3 py-1 text-xs font-semibold text-slate-700">
                        Section ID {sectionResult.section_id}
                      </span>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </section>
      </div>
    </main>
  )
}

export default SearchPage