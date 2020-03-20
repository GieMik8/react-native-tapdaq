import React, { Component } from 'react'
import { NativeSyntheticEvent, ViewStyle, requireNativeComponent, View } from 'react-native'

export interface TapdaqAd {
  placement?: string
  hasVideoContent?: boolean
}

export interface State {
  visible: boolean
  ready: boolean
  ad: TapdaqAd
}

interface Props {
  placement: string
  onLoadStart?: (e: NativeSyntheticEvent<any>) => void
  onClick?: (e: NativeSyntheticEvent<any>) => void
  onError?: (e: NativeSyntheticEvent<any>) => void
  onLoad?: (e: NativeSyntheticEvent<TapdaqAd>) => void
  onDestroy?: (e: NativeSyntheticEvent<any>) => void
  style?: ViewStyle
  imageStyle?: ViewStyle
}

const TapdaqNativeAdView = requireNativeComponent('TapdaqNativeAdView')

interface IncludesNativeAdComponentRef {
  nativeAdComponent: React.RefObject<unknown>
}

const styles = {
  root: {
    width: '100%',
    height: 290,
    opacity: 1,
  },
}

class MediatedNativeAd2 extends Component<Props, State> implements IncludesNativeAdComponentRef {
  public nativeAdComponent = React.createRef()

  constructor(props: Props) {
    super(props)
    this.state = {
      ad: {},
      visible: false,
      ready: false,
    }
  }

  public onLoad = (e: NativeSyntheticEvent<TapdaqAd>) => {
    this.setState({
      ready: true,
      ad: e.nativeEvent,
    })
    if (this.props.onLoad) {
      this.props.onLoad(e)
    }
  }

  public onLoadStart = (e: NativeSyntheticEvent<TapdaqAd>) => {
    this.setState({ ready: false, ad: {} })
    if (this.props.onLoadStart) {
      this.props.onLoadStart(e)
    }
  }

  public onError = (err: NativeSyntheticEvent<string>) => {
    console.debug(err.nativeEvent)
    if (this.props.onError) {
      this.props.onError(err)
    }
  }

  public render() {
    const { style, imageStyle, ...props } = this.props
    const finalStyle = { ...styles.root, ...style }
    if (!this.state.ready) {
      finalStyle.height = 0
      finalStyle.opacity = 0
    }
    console.log(this.state)

    return (
      <View style={{ backgroundColor: 'red', width: '100%', height: 300 }}>
        <TapdaqNativeAdView
          ref={(ref: any) => {
            this.nativeAdComponent = ref
          }}
          {...props}
          layout={{ margin: 12, middleHeight: 190 }}
          style={finalStyle}
          onCustomLoad={this.onLoad}
          onCustomError={this.onError}
          onCustomLoadStart={this.onLoadStart}
        />
      </View>
    )
  }
}

export default MediatedNativeAd2
