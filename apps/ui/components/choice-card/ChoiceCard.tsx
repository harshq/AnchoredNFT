"use client";

import React from "react";

interface Props<T extends { id: string }> {
    items: T[]
    value?: T
    onChange: (value: T) => void
    renderItem: (props: T, onChange: (value: T) => void, isActive: boolean) => React.ReactNode
}

export default function ChoiceCard<T extends { id: string }>({
    items,
    value,
    onChange,
    renderItem
}: Props<T>) {
    return (
        <div className="grid grid-cols-2 gap-2 w-full md:w-100">
            {
                items.map(item => {
                    const isActive = item.id === value?.id;
                    return renderItem(item, onChange, isActive);
                })
            }
        </div>
    )
}