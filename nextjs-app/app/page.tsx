import Link from "next/link";

export default async function IndexPage() {
  return (
    <div>
      <span>Hello public user!</span>
      <br />
      <Link href="/private">Login</Link>
    </div>
  );
}
