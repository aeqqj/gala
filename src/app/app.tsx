import { Outlet } from "react-router-dom";
import "./index.css";
import { NavigationBar } from "../components/navigation.tsx"

function App() {
  return (
    <>
      <NavigationBar />
      <main>
        <Outlet />
      </main>
    </>
  )
}
export default App
