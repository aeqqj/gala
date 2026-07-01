import { createBrowserRouter } from "react-router-dom";
import App from "./app";
import { EventPage } from "../features/event/event-page.tsx";
import { CalendarPage } from "../features/calendar/calendar-page.tsx";
import { MapPage } from "../features/map/map-page.tsx";
import { EventDetailsPage } from "../features/event-details/event-details-page.tsx";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    children: [
      { index: true, element: <EventPage /> },
      { path: "calendar", element: <CalendarPage /> },
      { path: "map", element: <MapPage /> },
      { path: "event-details", element: <EventDetailsPage /> },
    ],
  },
]);
