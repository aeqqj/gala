import { Ticket, Calendar, Map } from 'lucide-react';

export function NavigationBar() {
  return (
    <>
      <nav className="w-fit px-12 py-4 border rounded-4xl flex items-center justify-center">
        <div className="text-sm font-medium flex gap-8">
            <div className="flex gap-1 items-center"><Ticket className="-rotate-90" size={20}/>Events</div>
            <div className="flex gap-1 items-center"><Calendar size={18} />Calendar</div>
            <div className="flex gap-1 items-center"><Map size={18} />Map</div>
        </div>
      </nav>
    </>
  )
}
