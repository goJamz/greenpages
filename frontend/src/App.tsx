import { useEffect, useState } from 'react'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080'

function App() {
  const [health, setHealth] = useState<string>('checking...')

  useEffect(() => {
    fetch(`${API_URL}/api/health`)
      .then(r => r.json())
      .then(d => setHealth(d.status))
      .catch(() => setHealth('unreachable'))
  }, [])

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Green Pages</h1>
            <p className="text-sm text-gray-500">Army Directory &amp; Position Explorer</p>
          </div>
          <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${
            health === 'ok'
              ? 'bg-green-100 text-green-700'
              : 'bg-yellow-100 text-yellow-700'
          }`}>
            API: {health}
          </span>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-12">
        <div className="text-center">
          <h2 className="text-lg font-semibold text-gray-700 mb-2">Scaffold running</h2>
          <p className="text-gray-500 text-sm max-w-md mx-auto">
            Frontend, backend, and database containers are up. Next step: search endpoint and section page.
          </p>
        </div>
      </main>
    </div>
  )
}

export default App
