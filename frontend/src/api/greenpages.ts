const API_BASE = '/api'

export type SectionSearchResult = {
  section_id: number
  organization_id: number
  organization_name: string
  organization_short_name: string
  section_code: string
  section_name: string
  display_name: string
}

export type SectionSearchResponse = {
  query: string
  count: number
  results: SectionSearchResult[]
}

export type PersonSearchResult = {
  person_id: number
  display_name: string
  rank: string
  work_email: string
  work_phone: string
  office_symbol: string
  billet_id: number
  billet_title: string
  billet_grade_code: string
  billet_status: string
  section_id: number
  section_display_name: string
  organization_id: number
  organization_name: string
  organization_short_name: string
}

export type PersonSearchResponse = {
  query: string
  count: number
  results: PersonSearchResult[]
}

export type BilletOccupant = {
  person_id: number
  display_name: string
  rank: string
  work_email: string
  work_phone: string
  office_symbol: string
  is_primary: boolean
}

export type BilletResult = {
  billet_id: number
  position_number: string
  billet_title: string
  grade_code: string
  rank_group: string
  branch_code: string
  mos_code: string
  aoc_code: string
  component: string
  uic: string
  paragraph_number: string
  line_number: string
  duty_location: string
  state_code: string
  status: string
  occupants: BilletOccupant[]
}

export type SectionDetail = {
  section_id: number
  organization_id: number
  organization_name: string
  organization_short_name: string
  section_code: string
  section_name: string
  display_name: string
}

export type SectionDetailResponse = {
  section: SectionDetail
  billets: BilletResult[]
}

export type PersonDetail = {
  person_id: number
  display_name: string
  rank: string
  work_email: string
  work_phone: string
  office_symbol: string
  dod_id: string
}

export type PersonAssignment = {
  is_primary: boolean
  billet_id: number
  billet_title: string
  billet_grade_code: string
  position_number: string
  branch_code: string
  mos_code: string
  aoc_code: string
  component: string
  billet_status: string
  section_id: number
  section_code: string
  section_display_name: string
  organization_id: number
  organization_name: string
  organization_short_name: string
  uic: string
  paragraph_number: string
  line_number: string
  duty_location: string
  state_code: string
}

export type PersonDetailResponse = {
  person: PersonDetail
  assignments: PersonAssignment[]
}

export type ExplorerPositionFilters = {
  component: string
  grade: string
  branch: string
  mos: string
  aoc: string
  state: string
  status: string
  organization: string
}

export type ExplorerPositionResult = {
  billet_id: number
  position_number: string
  billet_title: string
  grade_code: string
  branch_code: string
  mos_code: string
  aoc_code: string
  component: string
  uic: string
  paragraph_number: string
  line_number: string
  duty_location: string
  state_code: string
  status: string
  organization_id: number
  organization_name: string
  organization_short_name: string
  section_id: number
  section_display_name: string
  primary_person_id: number
  primary_person_display_name: string
  primary_person_rank: string
}

export type ExplorerPositionsResponse = {
  filters: ExplorerPositionFilters
  count: number
  limit: number
  offset: number
  results: ExplorerPositionResult[]
}

type ErrorResponse = {
  error?: string
}

async function readJsonResponse<T>(httpResponse: Response): Promise<T> {
  let responseBody: unknown // Parsed response body from the backend.
  let parsedErrorBody: ErrorResponse // Narrowed backend error body when present.
  let errorMessage: string // Final user-facing error message.

  if (!httpResponse.ok) {
    try {
      responseBody = await httpResponse.json()
      parsedErrorBody = responseBody as ErrorResponse

      if (typeof parsedErrorBody.error === 'string' && parsedErrorBody.error.trim() !== '') {
        errorMessage = parsedErrorBody.error
      } else {
        errorMessage = 'Request failed'
      }
    } catch {
      errorMessage = 'Request failed'
    }

    throw new Error(errorMessage)
  }

  responseBody = await httpResponse.json()

  return responseBody as T
}

function buildExplorerQueryString(
  filters: Partial<ExplorerPositionFilters>,
  limit?: number,
  offset?: number,
): string {
  const queryParams = new URLSearchParams()

  if (filters.component && filters.component.trim() !== '') {
    queryParams.set('component', filters.component.trim())
  }

  if (filters.grade && filters.grade.trim() !== '') {
    queryParams.set('grade', filters.grade.trim())
  }

  if (filters.branch && filters.branch.trim() !== '') {
    queryParams.set('branch', filters.branch.trim())
  }

  if (filters.mos && filters.mos.trim() !== '') {
    queryParams.set('mos', filters.mos.trim())
  }

  if (filters.aoc && filters.aoc.trim() !== '') {
    queryParams.set('aoc', filters.aoc.trim())
  }

  if (filters.state && filters.state.trim() !== '') {
    queryParams.set('state', filters.state.trim())
  }

  if (filters.status && filters.status.trim() !== '') {
    queryParams.set('status', filters.status.trim())
  }

  if (filters.organization && filters.organization.trim() !== '') {
    queryParams.set('organization', filters.organization.trim())
  }

  if (typeof limit === 'number') {
    queryParams.set('limit', String(limit))
  }

  if (typeof offset === 'number') {
    queryParams.set('offset', String(offset))
  }

  return queryParams.toString()
}

export async function searchSections(query: string): Promise<SectionSearchResponse> {
  const httpResponse = await fetch(`${API_BASE}/sections/search?q=${encodeURIComponent(query)}`)

  return readJsonResponse<SectionSearchResponse>(httpResponse)
}

export async function searchPeople(query: string): Promise<PersonSearchResponse> {
  const httpResponse = await fetch(`${API_BASE}/people/search?q=${encodeURIComponent(query)}`)

  return readJsonResponse<PersonSearchResponse>(httpResponse)
}

export async function getSectionDetail(sectionID: string): Promise<SectionDetailResponse> {
  const httpResponse = await fetch(`${API_BASE}/sections/${encodeURIComponent(sectionID)}`)

  return readJsonResponse<SectionDetailResponse>(httpResponse)
}

export async function getPersonDetail(personID: string): Promise<PersonDetailResponse> {
  const httpResponse = await fetch(`${API_BASE}/people/${encodeURIComponent(personID)}`)

  return readJsonResponse<PersonDetailResponse>(httpResponse)
}

export async function getExplorerPositions(
  filters: Partial<ExplorerPositionFilters>,
  limit?: number,
  offset?: number,
): Promise<ExplorerPositionsResponse> {
  const queryString = buildExplorerQueryString(filters, limit, offset)
  const endpoint = queryString === '' ? `${API_BASE}/explorer/positions` : `${API_BASE}/explorer/positions?${queryString}`
  const httpResponse = await fetch(endpoint)

  return readJsonResponse<ExplorerPositionsResponse>(httpResponse)
}

export function buildExportPositionsURL(
  filters: Partial<ExplorerPositionFilters>,
): string {
  const queryString = buildExplorerQueryString(filters)
  const baseURL = `${API_BASE}/exports/positions`

  if (queryString === '') {
    return baseURL
  }

  return `${baseURL}?${queryString}`
}

export function buildExportSectionURL(sectionID: string | number): string {
  return `${API_BASE}/exports/section/${encodeURIComponent(String(sectionID))}`
}