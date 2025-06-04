"use client";

import { useEffect, useState } from "react";
import { Address, isHex, recoverMessageAddress } from "viem";

export function User({
  signature,
  timestamp,
}: {
  signature?: string;
  timestamp?: string;
}) {
  const [user, setUser] = useState<Address | undefined>(undefined);
  useEffect(() => {
    const domain = window.location.hostname;
    if (!isHex(signature)) {
      return;
    }
    if (
      !timestamp ||
      typeof timestamp !== "string" ||
      isNaN(Number(timestamp))
    ) {
      return;
    }

    recoverMessageAddress({
      message: `Xnode Auth authenticate ${domain} at ${timestamp}`,
      signature,
    }).then(setUser);
  }, [signature, timestamp]);

  return (
    <div>
      <span>Hello {user}!</span>
      <br />
      <button
        onClick={() => {
          fetch("/xnode-auth/api/logout", { method: "POST" }).then(() =>
            window.location.reload()
          );
        }}
      >
        Logout
      </button>
    </div>
  );
}
