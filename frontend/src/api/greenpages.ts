const API_BASE = '/api'

export interface SectionSearchResult {
  section_id: number
  organization_id: number
  organization_name: string
  organization_short_name: string
  section_code: string
  section_name: string
  display_name: string
}

export interface SectionSearchResponse {
  query: string
  count: number
  results: SectionSearchResult[]
}

export async function searchSections(query: string): Promise<SectionSearchResponse> {
  const response = await fetch(`${API_BASE}/sections/search?q=${encodeURIComponent(query)}`)
  if (!response.ok) {
    throw new Error(`search failed: ${response.status}`)
  }
  return response.json()
}