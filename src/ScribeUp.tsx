import React from "react";
import {
  NativeModules,
  Platform,
  NativeEventEmitter,
  EmitterSubscription,
} from "react-native";

const LINKING_ERROR =
  `The package 'scribeup-react-native-scribeup' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({
    ios: "- You have run 'pod install'\n",
    default: "",
  }) +
  "- You rebuilt the app after installing the package\n";

const Scribeup = NativeModules.Scribeup
  ? NativeModules.Scribeup
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      },
    );

const EXIT_EVENT = "ScribeupOnExit";
const EVENT_NAME = "ScribeupOnEvent";

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

export type ExitError = {
  code: number;
  message?: string;
};

type ExitPayload = { error?: ExitError; data?: JsonObject };
type EventPayload = { data?: JsonObject };

/**
 * ScribeUp component properties
 */
export interface ScribeUpProps {
  url: string;
  productName?: string;
  onExit?: (error: ExitError | null, data: JsonObject | null) => void;
  onEvent?: (data: JsonObject) => void;
}

/**
 * ScribeUp Component
 *
 * Presents the native UI on mount and wires callbacks via device events.
 * Safe against modules that don't implement addListener/removeListeners.
 */
class ScribeUp extends React.Component<ScribeUpProps> {
  private emitter?: NativeEventEmitter;
  private exitSub?: EmitterSubscription;
  private eventSub?: EmitterSubscription;
  private didExit = false;

  componentDidMount() {
    const { url, productName = "" } = this.props;

    // Use module-backed emitter only if it implements the listener API.
    const canAttach =
      Scribeup &&
      typeof (Scribeup as any).addListener === "function" &&
      typeof (Scribeup as any).removeListeners === "function";

    this.emitter = new NativeEventEmitter(canAttach ? (Scribeup as any) : undefined);

    // Subscribe to onExit
    this.exitSub = this.emitter.addListener(
      EXIT_EVENT,
      (payload?: ExitPayload) => {
        if (this.didExit) return;
        this.didExit = true;

        const error: ExitError | null = payload?.error
          ? { code: Number(payload.error.code ?? 1000), message: payload.error.message }
          : null;

        const data: JsonObject | null =
          payload?.data && typeof payload.data === "object"
            ? (payload.data as JsonObject)
            : null;

        this.props.onExit?.(error, data);
      },
    );

    // Subscribe to onEvent
    this.eventSub = this.emitter.addListener(
      EVENT_NAME,
      (payload?: EventPayload) => {
        const data =
          payload?.data && typeof payload.data === "object"
            ? (payload.data as JsonObject)
            : null;
        if (data) this.props.onEvent?.(data);
      },
    );

    // Present the native UI. Support both promise- and event-based native APIs.
    this.present(url, productName);
  }

  componentWillUnmount() {
    try {
      this.exitSub?.remove();
      this.eventSub?.remove();
    } finally {
      this.exitSub = undefined;
      this.eventSub = undefined;
      this.emitter = undefined;
    }
  }

  private present(url: string, productName: string) {
    if (!(Scribeup && typeof (Scribeup as any).presentWithUrl === "function")) {
      throw new Error(`ScribeUp: Native module not found for ${Platform.OS}`);
    }

    try {
      const ret = (Scribeup as any).presentWithUrl(url, productName);

      // If native returns a Promise, also resolve to onExit (guarded to avoid duplicate calls).
      if (ret && typeof ret.then === "function") {
        ret
          .then((result: any) => {
            if (this.didExit) return; // event already handled exit
            this.didExit = true;

            const error: ExitError | null = result?.error
              ? { code: Number(result.error.code ?? 1000), message: result.error.message }
              : null;

            const data: JsonObject | null =
              result && result.data && typeof result.data === "object"
                ? (result.data as JsonObject)
                : null;

            this.props.onExit?.(error, data);
          })
          .catch((err: any) => {
            if (this.didExit) return;
            this.didExit = true;
            this.props.onExit?.(
              { code: Number(err?.code ?? 1000), message: err?.message || "Unexpected Error" },
              null,
            );
          });
      }
    } catch (err: any) {
      if (this.didExit) return;
      this.didExit = true;
      this.props.onExit?.(
        { code: Number(err?.code ?? 1000), message: err?.message || "Unexpected Error" },
        null,
      );
    }
  }

  render() {
    return null;
  }
}

export default ScribeUp;
