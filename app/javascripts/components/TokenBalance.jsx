import React from 'react';

export default class TokenBalance extends React.Component {

  constructor (props) {
    super(props);
  }

  render() {
    return (
      <form action="">
        <h3>{this.props.tokenName}</h3>
        <div className="row">
          <div className="col-md-8">
            <label htmlFor="">Address:</label>
            <input type="text" className="form-control"/>
          </div>
        </div>
        <div className="row">
          <div className="col-md-8">
            <label htmlFor="">Balance:</label>
            <input type="text" className="form-control"/>
          </div>
        </div>
      </form>
      )
  }
}