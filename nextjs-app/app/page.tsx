import { User } from "@/components/user";
import { cookies as getCookies } from "next/headers";

export default async function IndexPage() {
  const cookies = await getCookies();
  return (
    <User
      signature={cookies.get("xnode_auth_signature")?.value}
      timestamp={cookies.get("xnode_auth_timestamp")?.value}
    />
  );
}
