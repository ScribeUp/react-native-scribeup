import React from "react";

/** JSON value types allowed inside data payloads */
export type JsonValue =
  | string
  | number
  | boolean
  | null
  | JsonObject
  | JsonValue[];

export interface JsonObject {
  [key: string]: JsonValue;
}

/** Error returned when the SDK process ends with failure */
export interface ExitError {
  code: number;
  message?: string;
}

/**
 * ScribeUp component properties
 */
export interface ScribeUpProps {
  url: string;
  productName?: string;
  onExit: (error: ExitError | null, data: JsonObject | null) => void;
  onEvent?: (data: JsonObject) => void;
}

/**
 * ScribeUp Component
 *
 * React component that displays the ScribeUp SDK interface when
 * mounted and invokes the callbacks as the user interacts with or
 * exits the flow.
 */
declare class ScribeUp extends React.Component<ScribeUpProps> {
  constructor(props: ScribeUpProps);
  componentDidMount(): void;
  private present;
  render(): any;
}

export default ScribeUp;
