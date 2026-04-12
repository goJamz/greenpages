import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router'
import { getSectionDetail } from '../api/greenpages'
import type { SectionDetailResponse, BilletResult, BilletOccupant } from '../api/greenpages'

function statusBadge(status: string) {
  let label: string   // Display text for the badge.
  let classes: string // Tailwind classes for the badge color.

  label = status

  if (status === 'Filled') {
    classes = 'bg-green-100 text-green-800'
  } else if (status === 'Vacant') {
    classes = 'bg-yellow-100 text-yellow-800'
  } else {
    classes = 'bg-slate-200 text-slate-600'
  }

  return (
    <span className={`inline-flex rounded-full px-3 py-1 text-xs font-semibold ${classes}`}>
      {label}
    </span>
  )
}

function OccupantRow({ occupant }: { occupant: BilletOccupant }) {
  return (
    <div className="flex flex-col gap-1 rounded-xl border border-slate-200 bg-white p-3">
      <div className="flex items-center gap-2">
        <span className="text-sm font-semibold text-slate-900">
          {occupant.rank !== '' ? `${occupant.rank} ` : ''}{occupant.display_name}
        </span>
        {occupant.is_primary ? (
          <span className="rounded-full bg-blue-100 px-2 py-0.5 text-xs font-semibold text-blue-700">
            Primary
          </span>
        ) : null}
      </div>

      {occupant.office_symbol !== '' ? (
        <p className="text-xs text-slate-500">{occupant.office_symbol}</p>
      ) : null}

      {occupant.work_email !== '' ? (
        <p className="text-xs text-slate-500">{occupant.work_email}</p>
      ) : null}

      {occupant.work_phone !== '' ? (
        <p className="text-xs text-slate-500">{occupant.work_phone}</p>
      ) : null}
    </div>
  )
}

function BilletCard({ billet }: { billet: BilletResult }) {
  let specParts: string[] = [] // Non-empty spec fields assembled for display.

  if (billet.grade_code !== '') specParts.push(billet.grade_code)
  if (billet.branch_code !== '') specParts.push(billet.branch_code)
  if (billet.mos_code !== '') specParts.push(billet.mos_code)
  if (billet.aoc_code !== '') specParts.push(billet.aoc_code)
  if (billet.component !== '') specParts.push(billet.component)

  return (
    <article className="rounded-2xl border border-slate-200 bg-slate-50 p-4">
      <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
        <div className="min-w-0">
          <h3 className="text-base font-semibold text-slate-900">{billet.billet_title}</h3>

          {specParts.length > 0 ? (
            <p className="mt-1 text-sm text-slate-500">{specParts.join(' · ')}</p>
          ) : null}

          {billet.duty_location !== '' ? (
            <p className="mt-1 text-xs text-slate-400">
              {billet.duty_location}{billet.state_code !== '' ? `, ${billet.state_code}` : ''}
            </p>
          ) : null}

          {billet.paragraph_number !== '' && billet.line_number !== '' ? (
            <p className="mt-1 text-xs text-slate-400">
              Para {billet.paragraph_number} · Line {billet.line_number}
            </p>
          ) : null}
        </div>

        <div className="shrink-0">
          {statusBadge(billet.status)}
        </div>
      </div>

      {billet.occupants.length > 0 ? (
        <div className="mt-3 grid gap-2">
          {billet.occupants.map((occupant) => (
            <OccupantRow key={occupant.person_id} occupant={occupant} />
          ))}
        </div>
      ) : null}
    </article>
  )
}

function SectionDetailPage() {
  let params = useParams<{ sectionID: string }>()  // URL params containing the section ID.

  let detailValue = useState<SectionDetailResponse | null>(null) // Loaded section detail response.
  let isLoadingValue = useState(true)                            // Whether the detail request is in flight.
  let errorMessageValue = useState('')                           // User-visible error message.

  let detail = detailValue[0]
  let setDetail = detailValue[1]

  let isLoading = isLoadingValue[0]
  let setIsLoading = isLoadingValue[1]

  let errorMessage = errorMessageValue[0]
  let setErrorMessage = errorMessageValue[1]

  useEffect(() => {
    let sectionID: number  // Parsed numeric section ID from the URL.

    if (params.sectionID === undefined) {
      setErrorMessage('No section ID in URL.')
      setIsLoading(false)
      return
    }

    sectionID = parseInt(params.sectionID, 10)

    if (isNaN(sectionID)) {
      setErrorMessage('Invalid section ID.')
      setIsLoading(false)
      return
    }

    getSectionDetail(sectionID)
      .then((response) => {
        setDetail(response)
      })
      .catch((fetchError: unknown) => {
        if (fetchError instanceof Error) {
          setErrorMessage(fetchError.message)
        } else {
          setErrorMessage('Failed to load section.')
        }
      })
      .finally(() => {
        setIsLoading(false)
      })
  }, [params.sectionID])

  return (
    <main className="min-h-screen bg-slate-100 text-slate-900">
      <div className="mx-auto flex max-w-5xl flex-col gap-6 px-4 py-10 sm:px-6 lg:px-8">
        <div>
          <Link
            to="/"
            className="text-sm font-medium text-slate-500 hover:text-slate-900"
          >
            ← Back to search
          </Link>
        </div>

        {isLoading ? (
          <div className="rounded-2xl border border-slate-200 bg-white p-6 text-sm text-slate-500">
            Loading section...
          </div>
        ) : null}

        {!isLoading && errorMessage !== '' ? (
          <div className="rounded-2xl border border-red-200 bg-red-50 p-6 text-sm text-red-700">
            {errorMessage}
          </div>
        ) : null}

        {!isLoading && detail !== null ? (
          <>
            <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">
                {detail.section.organization_name}
              </p>

              <h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-900">
                {detail.section.display_name}
              </h1>

              <p className="mt-2 text-sm text-slate-500">
                {detail.section.section_code} · {detail.section.section_name}
              </p>

              {detail.section.organization_short_name !== '' ? (
                <p className="mt-1 text-sm text-slate-400">
                  {detail.section.organization_short_name}
                </p>
              ) : null}

              <p className="mt-4 text-sm text-slate-600">
                {detail.billets.length} billet{detail.billets.length !== 1 ? 's' : ''}
              </p>
            </section>

            <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
              <h2 className="text-lg font-semibold text-slate-900">Billets</h2>

              {detail.billets.length === 0 ? (
                <div className="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-sm text-slate-500">
                  No billets found for this section.
                </div>
              ) : (
                <div className="mt-4 grid gap-4">
                  {detail.billets.map((billet) => (
                    <BilletCard key={billet.billet_id} billet={billet} />
                  ))}
                </div>
              )}
            </section>
          </>
        ) : null}
      </div>
    </main>
  )
}

export default SectionDetailPage