import React from "react";
import { formatNumberWithCommas, sanatiseNumberInput } from "@/utils/NumericInputFormatter";


interface Props extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "onChange"> {
    decimals: number
    onChange: (value: string) => void
}

export default function AmountInput({ value, onChange, decimals, ...props }: Props) {
    return (
        <input
            autoFocus
            {...props}
            className="text-5xl w-full text-right border-none outline-none"
            placeholder="0.00"
            value={formatNumberWithCommas(value as string)}
            onChange={(e) => {
                const safeValue = sanatiseNumberInput(e.target.value, true, decimals);
                onChange(safeValue);
            }} />
    )

}