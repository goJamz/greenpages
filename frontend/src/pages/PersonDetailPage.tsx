import { useEffect, useState } from 'react'
import { Link, useLocation, useParams } from 'react-router'
import { getPersonDetail, type PersonDetailResponse } from '../api/greenpages'

function renderStatusBadge(status: string) {
  let badgeClasses: string // Tailwind classes used to color the badge.

  if (status === 'Filled') {
    badgeClasses = 'bg-emerald-100 text-emerald-700'
  } else if (status === 'Vacant') {
    badgeClasses = 'bg-amber-100 text-amber-700'
  } else {
    badgeClasses = 'bg-slate-200 text-slate-700'
  }

  return (
    <span className={`inline-flex rounded-full px-3 py-1 text-xs font-semibold ${badgeClasses}`}>
      {status}
    </span>
  )
}

function PersonDetailPage() {
  const { personID } = useParams()
  const location = useLocation()

  const [personDetailResponse, setPersonDetailResponse] = useState<PersonDetailResponse | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [errorMessage, setErrorMessage] = useState('')

  useEffect(() => {
    let isCancelled = false

    async function loadPersonDetail() {
      let detailResponse

      if (!personID) {
        setErrorMessage('Person ID is required')
        setIsLoading(false)
        return
      }

      setIsLoading(true)
      setErrorMessage('')

      try {
        detailResponse = await getPersonDetail(personID)

        if (!isCancelled) {
          setPersonDetailResponse(detailResponse)
        }
      } catch (detailError) {
        if (!isCancelled) {
          setPersonDetailResponse(null)

          if (detailError instanceof Error) {
            setErrorMessage(detailError.message)
          } else {
            setErrorMessage('Failed to load person detail')
          }
        }
      } finally {
        if (!isCancelled) {
          setIsLoading(false)
        }
      }
    }

    loadPersonDetail()

    return () => {
      isCancelled = true
    }
  }, [personID])

  if (isLoading) {
    return (
      <main className="min-h-screen bg-slate-100 text-slate-900">
        <div className="mx-auto max-w-5xl px-4 py-10 sm:px-6 lg:px-8">
          <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
            <p className="text-sm text-slate-600">Loading person...</p>
          </div>
        </div>
      </main>
    )
  }

  if (errorMessage !== '') {
    return (
      <main className="min-h-screen bg-slate-100 text-slate-900">
        <div className="mx-auto max-w-5xl px-4 py-10 sm:px-6 lg:px-8">
          <div className="rounded-2xl border border-red-200 bg-white p-6 shadow-sm">
            <p className="text-sm text-red-700">{errorMessage}</p>
            <div className="mt-4">
              <Link
                to={{ pathname: '/', search: location.search }}
                className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-slate-700"
              >
                Back to search
              </Link>
            </div>
          </div>
        </div>
      </main>
    )
  }

  if (!personDetailResponse) {
    return null
  }

  return (
    <main className="min-h-screen bg-slate-100 text-slate-900">
      <div className="mx-auto flex max-w-5xl flex-col gap-6 px-4 py-10 sm:px-6 lg:px-8">
        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">
                Person detail
              </p>

              <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-900">
                {personDetailResponse.person.display_name}
              </h1>

              {(personDetailResponse.person.rank !== '' ||
                personDetailResponse.person.office_symbol !== '') ? (
                <p className="mt-3 text-sm leading-6 text-slate-600">
                  {personDetailResponse.person.rank || 'N/A'}
                  {personDetailResponse.person.office_symbol !== ''
                    ? ` · ${personDetailResponse.person.office_symbol}`
                    : ''}
                </p>
              ) : null}

              {personDetailResponse.person.work_email !== '' ? (
                <p className="mt-1 text-sm text-slate-500">
                  {personDetailResponse.person.work_email}
                </p>
              ) : null}

              {personDetailResponse.person.work_phone !== '' ? (
                <p className="mt-1 text-sm text-slate-500">
                  {personDetailResponse.person.work_phone}
                </p>
              ) : null}

              {personDetailResponse.person.dod_id !== '' ? (
                <p className="mt-1 text-xs text-slate-400">
                  DoD ID: {personDetailResponse.person.dod_id}
                </p>
              ) : null}
            </div>

            <div className="shrink-0">
              <Link
                to={{ pathname: '/', search: location.search }}
                className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-slate-700"
              >
                Back to search
              </Link>
            </div>
          </div>
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between gap-4">
            <h2 className="text-lg font-semibold text-slate-900">Assignments</h2>
            <span className="text-sm text-slate-500">
              {personDetailResponse.assignments.length} active
            </span>
          </div>

          {personDetailResponse.assignments.length === 0 ? (
            <div className="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-sm text-slate-500">
              No active assignments found for this person.
            </div>
          ) : (
            <div className="mt-4 grid gap-4">
              {personDetailResponse.assignments.map((assignmentResult) => (
                <article
                  key={`${assignmentResult.billet_id}-${assignmentResult.section_id}`}
                  className="rounded-2xl border border-slate-200 bg-slate-50 p-4"
                >
                  <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                    <div className="min-w-0">
                      <h3 className="text-lg font-semibold text-slate-900">
                        {assignmentResult.billet_title}
                      </h3>

                      <p className="mt-2 text-sm text-slate-600">
                        {assignmentResult.organization_name}
                        {' · '}
                        {assignmentResult.section_display_name}
                      </p>

                      <p className="mt-1 text-sm text-slate-500">
                        Grade {assignmentResult.billet_grade_code || 'N/A'}
                        {' · '}
                        Position {assignmentResult.position_number || 'N/A'}
                        {' · '}
                        {assignmentResult.component || 'N/A'}
                      </p>

                      <p className="mt-1 text-sm text-slate-500">
                        UIC {assignmentResult.uic || 'N/A'}
                        {' · '}
                        Paragraph/Line {assignmentResult.paragraph_number || 'N/A'}/{assignmentResult.line_number || 'N/A'}
                      </p>

                      {assignmentResult.duty_location !== '' ? (
                        <p className="mt-1 text-sm text-slate-500">
                          {assignmentResult.duty_location}
                          {assignmentResult.state_code !== '' ? `, ${assignmentResult.state_code}` : ''}
                        </p>
                      ) : null}
                    </div>

                    <div className="flex shrink-0 flex-col items-start gap-3 sm:items-end">
                      {renderStatusBadge(assignmentResult.billet_status)}

                      {assignmentResult.is_primary ? (
                        <span className="inline-flex rounded-full bg-blue-100 px-3 py-1 text-xs font-semibold text-blue-700">
                          Primary
                        </span>
                      ) : null}
                    </div>
                  </div>

                  <div className="mt-4">
                    <Link
                      to={{
                        pathname: `/sections/${assignmentResult.section_id}`,
                        search: location.search,
                      }}
                      className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-slate-700"
                    >
                      Open section
                    </Link>
                  </div>
                </article>
              ))}
            </div>
          )}
        </section>
      </div>
    </main>
  )
}

export default PersonDetailPage