import Lottie, { LottieRefCurrentProps } from "lottie-react";
import confetti from "@/public/animations/confetti.json";
import React from "react";

export default function SuccessAnimation() {
    const [isComplete, setIsComplete] = React.useState(false);
    if (isComplete) {
        return null;
    }
    return (
        <Lottie
            className="absolute top-0 right-0 left-0 bottom-0 z-100"
            animationData={confetti}
            loop={false}
            onComplete={() => {
                setIsComplete(true);
            }}
        />
    )
}