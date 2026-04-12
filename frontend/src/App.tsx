import { Routes, Route } from 'react-router'
import SearchPage from './pages/SearchPage'
import SectionDetailPage from './pages/SectionDetailPage'
import PersonDetailPage from './pages/PersonDetailPage'

function App() {
  return (
    <Routes>
      <Route path="/" element={<SearchPage />} />
      <Route path="/sections/:sectionID" element={<SectionDetailPage />} />
      <Route path="/people/:personID" element={<PersonDetailPage />} />
    </Routes>
  )
}

export default App