import { useState } from 'react'
import { searchSections } from '../api/greenpages'
import type { SectionSearchResult } from '../api/greenpages'

function SearchPage() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<SectionSearchResult[]>([])
  const [resultQuery, setResultQuery] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  async function handleSearch(e: React.FormEvent) {
    e.preventDefault()
    if (!query.trim()) return

    setLoading(true)
    setError('')

    try {
      const data = await searchSections(query)
      setResults(data.results)
      setResultQuery(data.query)
    } catch {
      setError('Search failed. Is the backend running?')
      setResults([])
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-3xl mx-auto px-6 py-12">
      <h1 className="text-3xl font-semibold text-gray-900 mb-2">Green Pages</h1>
      <p className="text-gray-500 mb-8">Search sections, people, and billets.</p>

      <form onSubmit={handleSearch} className="flex gap-3 mb-8">
        <input
          type="text"
          value={query}
          onChange={e => setQuery(e.target.value)}
          placeholder="Try: XVIII Airborne Corps G6"
          className="flex-1 border border-gray-300 rounded px-4 py-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <button
          type="submit"
          disabled={loading}
          className="bg-blue-600 text-white px-5 py-2 rounded hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? 'Searching...' : 'Search'}
        </button>
      </form>

      {error && (
        <p className="text-red-600 mb-6">{error}</p>
      )}

      {results.length > 0 && (
        <div>
          <p className="text-sm text-gray-500 mb-4">
            {results.length} result{results.length !== 1 ? 's' : ''} for "{resultQuery}"
          </p>
          <ul className="divide-y divide-gray-200 border border-gray-200 rounded">
            {results.map(section => (
              <li key={section.section_id} className="px-5 py-4">
                <p className="font-medium text-gray-900">{section.display_name}</p>
                <p className="text-sm text-gray-500">{section.organization_name}</p>
              </li>
            ))}
          </ul>
        </div>
      )}

      {!loading && resultQuery && results.length === 0 && (
        <p className="text-gray-500">No results found for "{resultQuery}".</p>
      )}
    </div>
  )
}

export default SearchPage