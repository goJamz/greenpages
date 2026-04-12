import { Routes, Route } from 'react-router'
import SearchPage from './pages/SearchPage'
import SectionDetailPage from './pages/SectionDetailPage'

function App() {
  return (
    <Routes>
      <Route path="/" element={<SearchPage />} />
      <Route path="/sections/:sectionID" element={<SectionDetailPage />} />
    </Routes>
  )
}

export default App