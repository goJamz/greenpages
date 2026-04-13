import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router'
import { getSectionDetail, type SectionDetailResponse } from '../api/greenpages'

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

function SectionDetailPage() {
  const { sectionID } = useParams()
  const [sectionDetailResponse, setSectionDetailResponse] = useState<SectionDetailResponse | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [errorMessage, setErrorMessage] = useState('')

  useEffect(() => {
    let isCancelled = false

    async function loadSectionDetail() {
      let detailResponse

      if (!sectionID) {
        setErrorMessage('Section ID is required')
        setIsLoading(false)
        return
      }

      setIsLoading(true)
      setErrorMessage('')

      try {
        detailResponse = await getSectionDetail(sectionID)

        if (!isCancelled) {
          setSectionDetailResponse(detailResponse)
        }
      } catch (detailError) {
        if (!isCancelled) {
          setSectionDetailResponse(null)

          if (detailError instanceof Error) {
            setErrorMessage(detailError.message)
          } else {
            setErrorMessage('Failed to load section detail')
          }
        }
      } finally {
        if (!isCancelled) {
          setIsLoading(false)
        }
      }
    }

    loadSectionDetail()

    return () => {
      isCancelled = true
    }
  }, [sectionID])

  if (isLoading) {
    return (
      <main className="min-h-screen bg-slate-100 text-slate-900">
        <div className="mx-auto max-w-5xl px-4 py-10 sm:px-6 lg:px-8">
          <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
            <p className="text-sm text-slate-600">Loading section...</p>
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
                to="/"
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

  if (!sectionDetailResponse) {
    return null
  }

  return (
    <main className="min-h-screen bg-slate-100 text-slate-900">
      <div className="mx-auto flex max-w-5xl flex-col gap-6 px-4 py-10 sm:px-6 lg:px-8">
        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">
                Section detail
              </p>

              <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-900">
                {sectionDetailResponse.section.display_name}
              </h1>

              <p className="mt-3 text-sm leading-6 text-slate-600">
                {sectionDetailResponse.section.organization_name}
                {' · '}
                {sectionDetailResponse.section.section_code}
                {' · '}
                {sectionDetailResponse.billets.length} billets
              </p>

              {sectionDetailResponse.section.organization_short_name !== '' ? (
                <p className="mt-1 text-sm text-slate-500">
                  {sectionDetailResponse.section.organization_short_name}
                </p>
              ) : null}
            </div>

            <div className="shrink-0">
              <Link
                to="/"
                className="inline-flex items-center justify-center rounded-xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-slate-700"
              >
                Back to search
              </Link>
            </div>
          </div>
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between gap-4">
            <h2 className="text-lg font-semibold text-slate-900">Billets</h2>
            <span className="text-sm text-slate-500">
              {sectionDetailResponse.billets.length} total
            </span>
          </div>

          {sectionDetailResponse.billets.length === 0 ? (
            <div className="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-sm text-slate-500">
              No billets found for this section.
            </div>
          ) : (
            <div className="mt-4 grid gap-4">
              {sectionDetailResponse.billets.map((billetResult) => (
                <article
                  key={billetResult.billet_id}
                  className="rounded-2xl border border-slate-200 bg-slate-50 p-4"
                >
                  <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                    <div className="min-w-0">
                      <h3 className="text-lg font-semibold text-slate-900">
                        {billetResult.billet_title}
                      </h3>

                      <p className="mt-2 text-sm text-slate-600">
                        Position {billetResult.position_number || 'N/A'}
                        {' · '}
                        Grade {billetResult.grade_code || 'N/A'}
                        {' · '}
                        {billetResult.component || 'N/A'}
                      </p>

                      <p className="mt-1 text-sm text-slate-500">
                        UIC {billetResult.uic || 'N/A'}
                        {' · '}
                        Paragraph/Line {billetResult.paragraph_number || 'N/A'}/{billetResult.line_number || 'N/A'}
                      </p>

                      <p className="mt-1 text-sm text-slate-500">
                        {billetResult.duty_location || 'N/A'}
                        {billetResult.state_code !== '' ? `, ${billetResult.state_code}` : ''}
                      </p>
                    </div>

                    <div className="flex shrink-0 flex-col items-start gap-3 sm:items-end">
                      {renderStatusBadge(billetResult.status)}

                      <span className="inline-flex rounded-full bg-slate-200 px-3 py-1 text-xs font-semibold text-slate-700">
                        Billet ID {billetResult.billet_id}
                      </span>
                    </div>
                  </div>

                  <div className="mt-4">
                    <h4 className="text-sm font-semibold uppercase tracking-[0.14em] text-slate-500">
                      Occupants
                    </h4>

                    {billetResult.occupants.length === 0 ? (
                      <p className="mt-2 text-sm text-slate-500">No occupant data returned.</p>
                    ) : (
                      <div className="mt-3 grid gap-3">
                        {billetResult.occupants.map((occupantResult) => (
                          <div
                            key={occupantResult.person_id}
                            className="rounded-xl border border-slate-200 bg-white px-4 py-3"
                          >
                            <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
                              <div>
                                <p className="font-semibold text-slate-900">
                                  <Link
                                    to={`/people/${occupantResult.person_id}`}
                                    className="hover:text-blue-700 hover:underline"
                                  >
                                    {occupantResult.rank !== '' ? `${occupantResult.rank} ` : ''}
                                    {occupantResult.display_name}
                                  </Link>
                                </p>

                                {occupantResult.office_symbol !== '' ? (
                                  <p className="mt-1 text-sm text-slate-600">
                                    {occupantResult.office_symbol}
                                  </p>
                                ) : null}

                                {occupantResult.work_email !== '' ? (
                                  <p className="mt-1 text-sm text-slate-500">
                                    {occupantResult.work_email}
                                  </p>
                                ) : null}

                                {occupantResult.work_phone !== '' ? (
                                  <p className="mt-1 text-sm text-slate-500">
                                    {occupantResult.work_phone}
                                  </p>
                                ) : null}
                              </div>

                              {occupantResult.is_primary ? (
                                <span className="inline-flex rounded-full bg-blue-100 px-3 py-1 text-xs font-semibold text-blue-700">
                                  Primary
                                </span>
                              ) : null}
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
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

export default SectionDetailPage