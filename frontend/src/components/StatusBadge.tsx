const statusBadgeStyles: Record<string, string> = {
  Filled: 'bg-emerald-100 text-emerald-700',
  Vacant: 'bg-amber-100 text-amber-700',
}

const defaultBadgeStyle = 'bg-slate-200 text-slate-700' // Used for Unknown and any unrecognized status.

export function renderStatusBadge(status: string) {
  let badgeClasses: string // Tailwind classes used to color the badge.

  badgeClasses = statusBadgeStyles[status] || defaultBadgeStyle

  return (
    <span className={`inline-flex rounded-full px-3 py-1 text-xs font-semibold ${badgeClasses}`}>
      {status}
    </span>
  )
}
