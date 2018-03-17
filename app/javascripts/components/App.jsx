import React from 'react';
import Nav from './Navigation.jsx'
import TokenBalance from './TokenBalance.jsx'
import {Exchange} from '../bootstrap_contracts';
const Web3 = require('web3');


export default class App extends React.Component {
  constructor (props) {
    super(props);
    this.state = {
      tokens : [
        {
          name: 'FIXED',
          address: ''
        }
      ]
    }

    if (typeof web3 !== 'undefined') {
      this.web3 = new Web3(web3.currentProvider);
    } else {
      // set the provider you want from Web3.providers
      this.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
      Exchange.setProvider(this.web3.currentProvider);
    }
  }


  async componentDidMount() {
    this.exchInst = await Exchange.deployed();
    var tokens = await this.exchInst.getTokens.call({from:this.web3.eth.accounts[0], gas:100000});
    console.log(tokens);
  }

  render() {
    return (
      <div className="container-fluid">
      <div className="row">
        <div className="col-md-8 offset-md-1">
          <Nav/>
        </div>
      </div>
        <div className="row">
          <div className="col-md-4">
          { this.state.tokens.map(function (token , index) {
            return <TokenBalance tokenName={token.name} key={index} tokenAddress={token.address} />
          })
          }
          </div>
        </div>
      </div>
  )
  }
}