export const PRECISION = 6;

export const sanatiseNumberInput = (
  value: string,
  withDecimals: boolean = true
) => {
  const raw = value.replace(/,/g, "");
  const cleaned = raw.replace(/[^0-9.]/g, "");
  const [integerRaw, decimalRaw] = cleaned.split(".");
  const integer = integerRaw.replace(/^0+(?!$)/, "") || "";

  if (!withDecimals || decimalRaw === undefined) {
    // Preserve trailing dot
    if (withDecimals && value.endsWith(".")) {
      return `${integer}.`;
    }
    return integer;
  }

  const decimal = decimalRaw.replace(/[^0-9]/g, "").slice(0, PRECISION);
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
