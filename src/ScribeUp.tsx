import React from "react";
import { NativeModules, Platform } from "react-native";

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
class ScribeUp extends React.Component<ScribeUpProps> {
  constructor(props: ScribeUpProps) {
    super(props);
  }

  componentDidMount() {
    const { url, productName, onExit } = this.props;
    this.present(url, productName, onExit);
  }

  private present(
    url: string,
    productName: string,
    onExit: (data?: ExitData) => void,
  ) {
    if (Scribeup && typeof Scribeup.presentWithUrl === "function") {
      try {
        Scribeup.presentWithUrl(url, productName)
          .then((result: any) => {
            onExit(result || {});
          })
          .catch((error: any) => {
            onExit({
              message: error?.message || "Unknown error",
              code: error?.code || -1,
            });
          });
      } catch (error: any) {
        onExit({
          message: error?.message || "Unknown error",
          code: error?.code || -1,
        });
      }
    } else {
      throw new Error(`ScribeUp: Native module not found for ${Platform.OS}`);
    }
  }

  render() {
    return null;
  }
}

export default ScribeUp;
