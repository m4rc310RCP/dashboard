import { FC, HtmlHTMLAttributes } from "react";

interface IndicatorProps {}

export const Indicator: FC<HtmlHTMLAttributes<unknown> & IndicatorProps> = (
  props,
) => {
  return (
    <div className={`${props.className} flex`}>
			<div className="w-[90%] h-[90%] relative flex my-auto mx-auto justify-center items-center">
				<div className="absolute w-[90%] h-[90%] bg-yellow-400 rounded-full"/>
				<div className="absolute w-[70%] h-[70%] bg-white animate-ping rounded-full"/>
			</div>
    </div>
  );
};
