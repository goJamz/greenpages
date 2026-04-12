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

type ErrorResponse = {
  error?: string
}

export async function searchSections(query: string): Promise<SectionSearchResponse> {
  let httpResponse: Response // Raw HTTP response from the backend.
  let responseBody: unknown // Parsed JSON body used for success or error inspection.
  let parsedErrorBody: ErrorResponse // Narrowed backend error payload when present.
  let errorMessage: string // Final user-facing error message.

  httpResponse = await fetch(`${API_BASE}/sections/search?q=${encodeURIComponent(query)}`)

  if (!httpResponse.ok) {
    try {
      responseBody = await httpResponse.json()
      parsedErrorBody = responseBody as ErrorResponse

      if (typeof parsedErrorBody.error === 'string' && parsedErrorBody.error.trim() !== '') {
        errorMessage = parsedErrorBody.error
      } else {
        errorMessage = 'Search request failed'
      }
    } catch {
      errorMessage = 'Search request failed'
    }

    throw new Error(errorMessage)
  }

  responseBody = await httpResponse.json()

  return responseBody as SectionSearchResponse
}