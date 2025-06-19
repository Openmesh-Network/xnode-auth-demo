import { Logout } from "@/components/logout";
import { headers } from "next/headers";
import Link from "next/link";

export default async function IndexPage() {
  const user = await headers().then((h) => h.get("Xnode-Auth-User"));
  return (
    <div>
      <span>Hello {user}!</span>
      <br />
      <Link href="/">Home</Link>
      <br />
      <Logout />
    </div>
  );
}
