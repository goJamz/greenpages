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

export async function searchSections(query: string): Promise<SectionSearchResponse> {
  let httpResponse: Response // Search response returned by the backend.

  httpResponse = await fetch(`${API_BASE}/sections/search?q=${encodeURIComponent(query)}`)

  return readJsonResponse<SectionSearchResponse>(httpResponse)
}

export async function searchPeople(query: string): Promise<PersonSearchResponse> {
  let httpResponse: Response // People search response returned by the backend.

  httpResponse = await fetch(`${API_BASE}/people/search?q=${encodeURIComponent(query)}`)

  return readJsonResponse<PersonSearchResponse>(httpResponse)
}

export async function getSectionDetail(sectionID: string): Promise<SectionDetailResponse> {
  let httpResponse: Response // Section detail response returned by the backend.

  httpResponse = await fetch(`${API_BASE}/sections/${encodeURIComponent(sectionID)}`)

  return readJsonResponse<SectionDetailResponse>(httpResponse)
}

export async function getPersonDetail(personID: string): Promise<PersonDetailResponse> {
  let httpResponse: Response // Person detail response returned by the backend.

  httpResponse = await fetch(`${API_BASE}/people/${encodeURIComponent(personID)}`)

  return readJsonResponse<PersonDetailResponse>(httpResponse)
}