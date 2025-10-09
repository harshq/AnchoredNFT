import { SYSTEM_DECIMALS } from "@/constants/base";

// @depricated
export const sanatiseNumberInput = (
  value: string,
  withDecimals: boolean = true,
  precision: number = SYSTEM_DECIMALS
) => {
  const cleaned = value.replace(/[^0-9.]/g, "");
  const [integerRaw, decimalRaw] = cleaned.split(".");
  const integer = integerRaw.replace(/^0+(?!$)/, "") || "";

  if (!withDecimals || decimalRaw === undefined) {
    // Preserve trailing dot
    if (withDecimals && value.endsWith(".")) {
      return `${integer}.`;
    }
    return integer;
  }

  const decimal = decimalRaw.replace(/[^0-9]/g, "").slice(0, precision);
  return `${integer}.${decimal}`;
};

export const formatNumberWithCommas = (value: string) => {
  const [int, dec] = value.split(".");
  const intFormatted = int ? Number(int).toLocaleString("en-US") : "";
  if (dec !== undefined) {
    return `${intFormatted}.${dec}`;
  } else {
    if (value.endsWith(".")) {
      return `${intFormatted}.`;
    } else {
      return `${intFormatted}`;
    }
  }
};
