import React from "react";
/**
 * Data type returned when the SDK process ends
 */
export type ExitData = {
    message?: string;
    code?: number;
};
/**
 * ScribeUp component properties
 */
export interface ScribeUpProps {
    url: string;
    productName: string;
    onExit: (data?: ExitData) => void;
}
/**
 * ScribeUp Component
 *
 * React component that displays the ScribeUp SDK interface when
 * mounted and invokes the onExit callback when the user completes or
 * cancels the process.
 */
declare class ScribeUp extends React.Component<ScribeUpProps> {
    constructor(props: ScribeUpProps);
    componentDidMount(): void;
    private present;
    render(): any;
}
export default ScribeUp;
