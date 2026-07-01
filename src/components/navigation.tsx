import { NavLink } from "react-router-dom";
import { Ticket, Calendar, Map } from 'lucide-react';

export function NavigationBar() {
  const linkClass = ({ isActive }: { isActive: boolean }, extra = "") =>
    `${isActive ? "nav-link active" : "nav-link"} ${extra}`;

  return (
    <nav className="w-fit px-12 py-4 border rounded-4xl flex items-center justify-center">
      <div className="text-sm font-medium flex gap-8">

        <NavLink
          to="calendar"
          className={(props) => linkClass(props, "flex gap-1 items-center")}
        >
          <Calendar size={18} />
          Calendar
        </NavLink>

        <NavLink
          to="/"
          end
          className={(props) => linkClass(props, "flex gap-1 items-center")}
        >
          <Ticket className="-rotate-90" size={20} />
          Events
        </NavLink>

        <NavLink
          to="map"
          className={(props) => linkClass(props, "flex gap-1 items-center")}
        >
          <Map size={18} />
          Map
        </NavLink>
      </div>
    </nav>
  );
}
