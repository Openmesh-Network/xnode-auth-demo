"use client";

export function Logout() {
  return (
    <button
      onClick={() => {
        fetch("/xnode-auth/api/logout", { method: "POST" }).then(() =>
          window.location.reload()
        );
      }}
    >
      Logout
    </button>
  );
}
