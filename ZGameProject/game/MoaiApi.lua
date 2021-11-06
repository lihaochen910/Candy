---@class MOAIAction
MOAIAction = { }

---@param child MOAIAction
---@param defer boolean
---@return MOAIAction
function MOAIAction:addChild(child, defer) end

---@param parent MOAIAction
---@param defer boolean
---@return MOAIAction
function MOAIAction:attach(parent, defer) end

---@return MOAIAction
function MOAIAction:clear() end

function MOAIAction:defer() end

---@return MOAIAction
function MOAIAction:detach() end

---@return ...
function MOAIAction:getChildren() end

---@return boolean
---@return number
function MOAIAction:hasChildren() end

---@return boolean
function MOAIAction:isActive() end

---@return boolean
function MOAIAction:isBusy() end

---@return boolean
function MOAIAction:isDone() end

---@return bool
function MOAIAction:isPaused() end

---@param pause boolean
function MOAIAction:pause(pause) end

function MOAIAction:setAutoStop() end

---@param parent MOAIAction
---@param defer boolean
---@return MOAIAction
function MOAIAction:start(parent, defer) end

---@return MOAIAction
function MOAIAction:stop() end

---@param throttle number
---@return MOAIAction
function MOAIAction:throttle(throttle) end

---@param step number
---@return MOAIAction
function MOAIAction:update(step) end


---@class MOAIActionTree
MOAIActionTree = { }

---@return MOAIAction
function MOAIActionTree.getRoot() end

---@param enable boolean
function MOAIActionTree.setProfilingEnabled(enable) end

---@param root MOAIAction
function MOAIActionTree.setRoot(root) end

---@param enable boolean
function MOAIActionTree.setThreadInfoEnabled(enable) end


---@class MOAIAnim
MOAIAnim = { }

---@param t0 number
function MOAIAnim:apply(t0) end

---@return number
function MOAIAnim:getLength() end

---@param nLinks number
function MOAIAnim:reserveLinks(nLinks) end

---@param linkID number
---@param curve MOAIAnimCurveBase
---@param target MOAINode
---@param attrID number
---@param asDelta boolean
function MOAIAnim:setLink(linkID, curve, target, attrID, asDelta) end


---@class MOAIAnimCurve
MOAIAnimCurve = { }

---@param time number
---@return number
function MOAIAnimCurve:getValueAtTime(time) end

---@param start number
---@param end number
---@return number
---@return number
function MOAIAnimCurve:getValueRange(start, endd) end

---@param index number
---@param time number
---@param value number
---@param mode number
---@param weight number
function MOAIAnimCurve:setKey(index, time, value, mode, weight) end


---@class MOAIAnimCurveBase
MOAIAnimCurveBase = { }

---@return number
function MOAIAnimCurveBase:getLength() end

---@param nKeys number
function MOAIAnimCurveBase:reserveKeys(nKeys) end

---@param mode number
function MOAIAnimCurveBase:setWrapMode(mode) end


---@class MOAIAnimCurveQuat
MOAIAnimCurveQuat = { }

---@param time number
---@return number
---@return number
---@return number
function MOAIAnimCurveQuat:getValueAtTime(time) end

---@param index number
---@param time number
---@param xRot number
---@param yRot number
---@param zRot number
---@param mode number
---@param weight number
function MOAIAnimCurveQuat:setKey(index, time, xRot, yRot, zRot, mode, weight) end


---@class MOAIAnimCurveVec
MOAIAnimCurveVec = { }

---@param time number
---@return number
---@return number
---@return number
function MOAIAnimCurveVec:getValueAtTime(time) end

---@param index number
---@param time number
---@param x number
---@param y number
---@param z number
---@param mode number
---@param weight number
function MOAIAnimCurveVec:setKey(index, time, x, y, z, mode, weight) end


---@class MOAIAppAndroid
MOAIAppAndroid = { }

---@return number
function MOAIAppAndroid.getStatusBarHeight() end

---@return number
function MOAIAppAndroid.getSystemUptime() end

---@return number
function MOAIAppAndroid.getUTCTime() end

---@param recipient string
---@param subject string
---@param message string
function MOAIAppAndroid.sendMail(recipient, subject, message) end

---@param prompt string
---@param subject string
---@param text string
function MOAIAppAndroid.share(prompt, subject, text) end


---@class MOAIAudioSamplerCocoa
MOAIAudioSamplerCocoa = { }


---@class MOAIBillingAndroid
MOAIBillingAndroid = { }

---@return boolean
function MOAIBillingAndroid.checkBillingSupported() end

---@return boolean
function MOAIBillingAndroid.checkInAppSupported() end

---@return boolean
function MOAIBillingAndroid.checkSubscriptionSupported() end

---@param notification string
---@return boolean
function MOAIBillingAndroid.confirmNotification(notification) end

---@param token string
function MOAIBillingAndroid.consumePurchaseSync(token) end

---@param type number
---@param continuation string
---@return string
function MOAIBillingAndroid.getPurchasedProducts(type, continuation) end

---@return boolean
function MOAIBillingAndroid.getUserId() end

---@param sku string
---@param type number
---@param devPayload string
function MOAIBillingAndroid.purchaseProduct(sku, type, devPayload) end

---@param sku string
---@param type int
---@param devPayload string
function MOAIBillingAndroid.purchaseProductFortumo(sku, type, devPayload) end

---@param skus table
---@param type number
---@return string
function MOAIBillingAndroid.requestProductsSync(skus, type) end

---@param sku string
---@param payload string
---@return boolean
function MOAIBillingAndroid.requestPurchase(sku, payload) end

---@param offset string
---@return boolean
function MOAIBillingAndroid.restoreTransactions(offset) end

---@param provider number
---@return boolean
function MOAIBillingAndroid.setBillingProvider(provider) end

---@param key string
function MOAIBillingAndroid.setPublicKey(key) end


---@class MOAIBitmapFontReader
MOAIBitmapFontReader = { }

---@param filename string
---@param charCodes string
---@param points number
---@param dpi number
function MOAIBitmapFontReader:loadPage(filename, charCodes, points, dpi) end


---@class MOAIBox2DArbiter
MOAIBox2DArbiter = { }

---@return number
---@return number
function MOAIBox2DArbiter:getContactNormal() end

---@return number
---@return number
---@return number
---@return number
function MOAIBox2DArbiter:getContactPoints() end

---@return number
function MOAIBox2DArbiter:getNormalImpulse() end

---@return number
function MOAIBox2DArbiter:getTangentImpulse() end

---@param enabled boolean
function MOAIBox2DArbiter:setContactEnabled(enabled) end


---@class MOAIBox2DBody
MOAIBox2DBody = { }

---@param verts table
---@param closeChain boolean
---@return MOAIBox2DFixture
function MOAIBox2DBody:addChain(verts, closeChain) end

---@param x number
---@param y number
---@param radius number
---@return MOAIBox2DFixture
function MOAIBox2DBody:addCircle(x, y, radius) end

---@param verts table
---@return table
function MOAIBox2DBody:addEdges(verts) end

---@param verts table
---@return MOAIBox2DFixture
function MOAIBox2DBody:addPolygon(verts) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
---@param angle number
---@return MOAIBox2DFixture
function MOAIBox2DBody:addRect(xMin, yMin, xMax, yMax, angle) end

---@param angularImpulse number
---@param wake boolean
function MOAIBox2DBody:applyAngularImpulse(angularImpulse, wake) end

---@param forceX number
---@param forceY number
---@param pointX number
---@param pointY number
---@param wake boolean
function MOAIBox2DBody:applyForce(forceX, forceY, pointX, pointY, wake) end

---@param impulseX number
---@param impulseY number
---@param pointX number
---@param pointY number
---@param wake boolean
function MOAIBox2DBody:applyLinearImpulse(impulseX, impulseY, pointX, pointY, wake) end

---@param torque number
---@param wake boolean
function MOAIBox2DBody:applyTorque(torque, wake) end

function MOAIBox2DBody:destroy() end

---@return number
function MOAIBox2DBody:getAngle() end

---@return number
function MOAIBox2DBody:getAngularVelocity() end

---@param touching boolean
---@return ...
function MOAIBox2DBody:getContactList(touching) end

---@return number
function MOAIBox2DBody:getGravityScale() end

---@return number
function MOAIBox2DBody:getInertia() end

---@return number
---@return number
function MOAIBox2DBody:getLinearVelocity() end

---@return number
---@return number
function MOAIBox2DBody:getLocalCenter() end

---@return number
function MOAIBox2DBody:getMass() end

---@return number
---@return number
function MOAIBox2DBody:getPosition() end

---@return number
---@return number
function MOAIBox2DBody:getWorldCenter() end

---@return boolean
function MOAIBox2DBody:isActive() end

---@return boolean
function MOAIBox2DBody:isAwake() end

---@return boolean
function MOAIBox2DBody:isBullet() end

---@return boolean
function MOAIBox2DBody:isFixedRotation() end

function MOAIBox2DBody:resetMassData() end

---@param active boolean
function MOAIBox2DBody:setActive(active) end

---@param damping number
function MOAIBox2DBody:setAngularDamping(damping) end

---@param omega number
function MOAIBox2DBody:setAngularVelocity(omega) end

---@param awake boolean
function MOAIBox2DBody:setAwake(awake) end

---@param bullet boolean
function MOAIBox2DBody:setBullet(bullet) end

---@param fixedRotation boolean
function MOAIBox2DBody:setFixedRotation(fixedRotation) end

---@param gravityScale. number
function MOAIBox2DBody:setGravityScale(gravityScale) end

---@param damping number
function MOAIBox2DBody:setLinearDamping(damping) end

---@param velocityX number
---@param velocityY number
function MOAIBox2DBody:setLinearVelocity(velocityX, velocityY) end

---@param mass number
---@param I number
---@param centerX number
---@param centerY number
function MOAIBox2DBody:setMassData(mass, I, centerX, centerY) end

---@param positionX number
---@param positionY number
---@param angle number
function MOAIBox2DBody:setTransform(positionX, positionY, angle) end

---@param type number
function MOAIBox2DBody:setType(type) end


---@class MOAIBox2DDistanceJoint
MOAIBox2DDistanceJoint = { }

---@return number
function MOAIBox2DDistanceJoint:getDampingRatio() end

---@return number
function MOAIBox2DDistanceJoint:getFrequency() end

---@return number
function MOAIBox2DDistanceJoint:getLength() end

---@param dampingRatio number
function MOAIBox2DDistanceJoint:setDampingRatio(dampingRatio) end

---@param frequency number
function MOAIBox2DDistanceJoint:setFrequency(frequency) end

---@param length number
function MOAIBox2DDistanceJoint:setLength(length) end


---@class MOAIBox2DFixture
MOAIBox2DFixture = { }

function MOAIBox2DFixture:destroy() end

---@return MOAIBox2DBody
function MOAIBox2DFixture:getBody() end

---@return number
---@return number
---@return number
function MOAIBox2DFixture:getFilter() end

---@param handler function
---@param phaseMask number
---@param categoryMask number
function MOAIBox2DFixture:setCollisionHandler(handler, phaseMask, categoryMask) end

---@param density number
function MOAIBox2DFixture:setDensity(density) end

---@param categoryBits number
---@param maskBits number
---@param groupIndex number
function MOAIBox2DFixture:setFilter(categoryBits, maskBits, groupIndex) end

---@param friction number
function MOAIBox2DFixture:setFriction(friction) end

---@param restitution number
function MOAIBox2DFixture:setRestitution(restitution) end

---@param isSensor boolean
function MOAIBox2DFixture:setSensor(isSensor) end


---@class MOAIBox2DFrictionJoint
MOAIBox2DFrictionJoint = { }

---@return number
function MOAIBox2DFrictionJoint:getMaxForce() end

---@return number
function MOAIBox2DFrictionJoint:getMaxTorque() end

---@param maxForce number
function MOAIBox2DFrictionJoint:setMaxForce(maxForce) end

---@param maxTorque number
function MOAIBox2DFrictionJoint:setMaxTorque(maxTorque) end


---@class MOAIBox2DGearJoint
MOAIBox2DGearJoint = { }

---@return MOAIBox2DJoint
function MOAIBox2DGearJoint:getJointA() end

---@return MOAIBox2DJoint
function MOAIBox2DGearJoint:getJointB() end

---@return number
function MOAIBox2DGearJoint:getRatio() end

---@param ratio number
function MOAIBox2DGearJoint:setRatio(ratio) end


---@class MOAIBox2DJoint
MOAIBox2DJoint = { }

function MOAIBox2DJoint:destroy() end

---@return number
---@return number
function MOAIBox2DJoint:getAnchorA() end

---@return number
---@return number
function MOAIBox2DJoint:getAnchorB() end

---@return MOAIBox2DBody
function MOAIBox2DJoint:getBodyA() end

---@return MOAIBox2DBody
function MOAIBox2DJoint:getBodyB() end

---@return number
---@return number
function MOAIBox2DJoint:getReactionForce() end

---@return number
function MOAIBox2DJoint:getReactionTorque() end


---@class MOAIBox2DMotorJoint
MOAIBox2DMotorJoint = { }

---@return number
function MOAIBox2DMotorJoint:getAngularOffset() end

---@return number
function MOAIBox2DMotorJoint:getCorrectionFactor() end

---@return number
---@return number
function MOAIBox2DMotorJoint:getLinearOffset() end

---@return number
function MOAIBox2DMotorJoint:getMaxForce() end

---@return number
function MOAIBox2DMotorJoint:getMaxTorque() end

---@param angle number
function MOAIBox2DMotorJoint:setAngularOffset(angle) end

---@param factor number
function MOAIBox2DMotorJoint:setCorrectionFactor(factor) end

---@param x number
---@param y number
function MOAIBox2DMotorJoint:setLinearOffset(x, y) end

---@param force number
function MOAIBox2DMotorJoint:setMaxForce(force) end

---@param torque number
function MOAIBox2DMotorJoint:setMaxTorque(torque) end


---@class MOAIBox2DMouseJoint
MOAIBox2DMouseJoint = { }

---@return number
function MOAIBox2DMouseJoint:getDampingRatio() end

---@return number
function MOAIBox2DMouseJoint:getFrequency() end

---@return number
function MOAIBox2DMouseJoint:getMaxForce() end

---@return number
---@return number
function MOAIBox2DMouseJoint:getTarget() end

---@param dampingRatio number
function MOAIBox2DMouseJoint:setDampingRatio(dampingRatio) end

---@param frequency number
function MOAIBox2DMouseJoint:setFrequency(frequency) end

---@param maxForce number
function MOAIBox2DMouseJoint:setMaxForce(maxForce) end

---@param x number
---@param y number
function MOAIBox2DMouseJoint:setTarget(x, y) end


---@class MOAIBox2DPrismaticJoint
MOAIBox2DPrismaticJoint = { }

---@return number
function MOAIBox2DPrismaticJoint:getJointSpeed() end

---@return number
function MOAIBox2DPrismaticJoint:getJointTranslation() end

---@return number
function MOAIBox2DPrismaticJoint:getLowerLimit() end

---@return number
function MOAIBox2DPrismaticJoint:getMotorForce() end

---@return number
function MOAIBox2DPrismaticJoint:getMotorSpeed() end

---@return number
function MOAIBox2DPrismaticJoint:getUpperLimit() end

---@return boolean
function MOAIBox2DPrismaticJoint:isLimitEnabled() end

---@return boolean
function MOAIBox2DPrismaticJoint:isMotorEnabled() end

---@param lower number
---@param upper number
function MOAIBox2DPrismaticJoint:setLimit(lower, upper) end

---@param enabled boolean
function MOAIBox2DPrismaticJoint:setLimitEnabled(enabled) end

---@param maxMotorForce number
function MOAIBox2DPrismaticJoint:setMaxMotorForce(maxMotorForce) end

---@param speed number
---@param maxForce number
---@param forceEnable boolean
function MOAIBox2DPrismaticJoint:setMotor(speed, maxForce, forceEnable) end

---@param enabled boolean
function MOAIBox2DPrismaticJoint:setMotorEnabled(enabled) end

---@param motorSpeed number
function MOAIBox2DPrismaticJoint:setMotorSpeed(motorSpeed) end


---@class MOAIBox2DPulleyJoint
MOAIBox2DPulleyJoint = { }

---@return number
---@return number
function MOAIBox2DPulleyJoint:getGroundAnchorA() end

---@return number
---@return number
function MOAIBox2DPulleyJoint:getGroundAnchorB() end

---@return number
function MOAIBox2DPulleyJoint:getLength1() end

---@return number
function MOAIBox2DPulleyJoint:getLength2() end

---@return number
function MOAIBox2DPulleyJoint:getRatio() end


---@class MOAIBox2DRevoluteJoint
MOAIBox2DRevoluteJoint = { }

---@return number
function MOAIBox2DRevoluteJoint:getJointAngle() end

---@return number
function MOAIBox2DRevoluteJoint:getJointSpeed() end

---@return number
function MOAIBox2DRevoluteJoint:getLowerLimit() end

---@return number
function MOAIBox2DRevoluteJoint:getMotorSpeed() end

---@return number
function MOAIBox2DRevoluteJoint:getMotorTorque() end

---@return number
function MOAIBox2DRevoluteJoint:getUpperLimit() end

---@return boolean
function MOAIBox2DRevoluteJoint:isLimitEnabled() end

---@return boolean
function MOAIBox2DRevoluteJoint:isMotorEnabled() end

---@param lower number
---@param upper number
function MOAIBox2DRevoluteJoint:setLimit(lower, upper) end

---@param enabled boolean
function MOAIBox2DRevoluteJoint:setLimitEnabled(enabled) end

---@param maxMotorTorque number
function MOAIBox2DRevoluteJoint:setMaxMotorTorque(maxMotorTorque) end

---@param speed number
---@param maxMotorTorque number
---@param forceEnable boolean
function MOAIBox2DRevoluteJoint:setMotor(speed, maxMotorTorque, forceEnable) end

---@param enabled boolean
function MOAIBox2DRevoluteJoint:setMotorEnabled(enabled) end

---@param motorSpeed number
function MOAIBox2DRevoluteJoint:setMotorSpeed(motorSpeed) end


---@class MOAIBox2DRopeJoint
MOAIBox2DRopeJoint = { }

---@return number
function MOAIBox2DRopeJoint:getLimitState() end

---@return number
function MOAIBox2DRopeJoint:getMaxLength() end

---@param maxLength number
function MOAIBox2DRopeJoint:setMaxLength(maxLength) end


---@class MOAIBox2DWeldJoint
MOAIBox2DWeldJoint = { }

---@param self MOAIBox2DDistanceJoint
---@return number
function MOAIBox2DWeldJoint.getDampingRatio(self) end

---@param self MOAIBox2DDistanceJoint
---@return number
function MOAIBox2DWeldJoint.getFrequency(self) end

---@param self MOAIBox2DDistanceJoint
---@param dampingRatio number
function MOAIBox2DWeldJoint.setDampingRatio(self, dampingRatio) end

---@param self MOAIBox2DDistanceJoint
---@param frequency number
function MOAIBox2DWeldJoint.setFrequency(self, frequency) end


---@class MOAIBox2DWheelJoint
MOAIBox2DWheelJoint = { }

---@return number
function MOAIBox2DWheelJoint:getJointSpeed() end

---@return number
function MOAIBox2DWheelJoint:getJointTranslation() end

---@return number
function MOAIBox2DWheelJoint:getMaxMotorTorque() end

---@return number
function MOAIBox2DWheelJoint:getMotorSpeed() end

---@return number
function MOAIBox2DWheelJoint:getMotorTorque() end

---@return number
function MOAIBox2DWheelJoint:getSpringDampingRatio() end

---@return number
function MOAIBox2DWheelJoint:getSpringFrequencyHz() end

---@return boolean
function MOAIBox2DWheelJoint:isMotorEnabled() end

---@param maxMotorTorque number
function MOAIBox2DWheelJoint:setMaxMotorTorque(maxMotorTorque) end

---@param speed number
---@param maxMotorTorque number
---@param forceEnable boolean
function MOAIBox2DWheelJoint:setMotor(speed, maxMotorTorque, forceEnable) end

---@param enabled boolean
function MOAIBox2DWheelJoint:setMotorEnabled(enabled) end

---@param motorSpeed number
function MOAIBox2DWheelJoint:setMotorSpeed(motorSpeed) end

---@param dampingRatio number
function MOAIBox2DWheelJoint:setSpringDampingRatio(dampingRatio) end

---@param springFrequencyHz number
function MOAIBox2DWheelJoint:setSpringFrequencyHz(springFrequencyHz) end


---@class MOAIBox2DWorld
MOAIBox2DWorld = { }

---@param type number
---@param x number
---@param y number
---@return MOAIBox2DBody
function MOAIBox2DWorld:addBody(type, x, y) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param anchorA_X number
---@param anchorA_Y number
---@param anchorB_X number
---@param anchorB_Y number
---@param frequencyHz number
---@param dampingRatio number
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addDistanceJoint(bodyA, bodyB, anchorA_X, anchorA_Y, anchorB_X, anchorB_Y, frequencyHz, dampingRatio, collideConnected) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param anchorX number
---@param anchorY number
---@param maxForce number
---@param maxTorque number
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addFrictionJoint(bodyA, bodyB, anchorX, anchorY, maxForce, maxTorque, collideConnected) end

---@param jointA MOAIBox2DJoint
---@param jointB MOAIBox2DJoint
---@param ratio number
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addGearJoint(jointA, jointB, ratio, collideConnected) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addMotorJoint(bodyA, bodyB, collideConnected) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param targetX number
---@param targetY number
---@param maxForce number
---@param frequencyHz number
---@param dampingRatio number
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addMouseJoint(bodyA, bodyB, targetX, targetY, maxForce, frequencyHz, dampingRatio, collideConnected) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param anchorA number
---@param anchorB number
---@param axisA number
---@param axisB number
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addPrismaticJoint(bodyA, bodyB, anchorA, anchorB, axisA, axisB, collideConnected) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param groundAnchorA_X number
---@param groundAnchorA_Y number
---@param groundAnchorB_X number
---@param groundAnchorB_Y number
---@param anchorA_X number
---@param anchorA_Y number
---@param anchorB_X number
---@param anchorB_Y number
---@param ratio number
---@param maxLengthA number
---@param maxLengthB number
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addPulleyJoint(bodyA, bodyB, groundAnchorA_X, groundAnchorA_Y, groundAnchorB_X, groundAnchorB_Y, anchorA_X, anchorA_Y, anchorB_X, anchorB_Y, ratio, maxLengthA, maxLengthB, collideConnected) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param anchorX number
---@param anchorY number
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addRevoluteJoint(bodyA, bodyB, anchorX, anchorY, collideConnected) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param anchorA_X number
---@param anchorA_Y number
---@param anchorB_X number
---@param anchorB_Y number
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addRevoluteJointLocal(bodyA, bodyB, anchorA_X, anchorA_Y, anchorB_X, anchorB_Y) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param maxLength number
---@param anchorAX number
---@param anchorAY number
---@param anchorBX number
---@param anchorBY number
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addRopeJoint(bodyA, bodyB, maxLength, anchorAX, anchorAY, anchorBX, anchorBY, collideConnected) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param anchorX number
---@param anchorY number
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addWeldJoint(bodyA, bodyB, anchorX, anchorY, collideConnected) end

---@param bodyA MOAIBox2DBody
---@param bodyB MOAIBox2DBody
---@param anchorX number
---@param anchorY number
---@param axisX number
---@param axisY number
---@param collideConnected boolean
---@return MOAIBox2DJoint
function MOAIBox2DWorld:addWheelJoint(bodyA, bodyB, anchorX, anchorY, axisX, axisY, collideConnected) end

---@return number
function MOAIBox2DWorld:getAngularSleepTolerance() end

---@return boolean
function MOAIBox2DWorld:getAutoClearForces() end

---@return number
---@return number
function MOAIBox2DWorld:getGravity() end

---@return number
function MOAIBox2DWorld:getLinearSleepTolerance() end

---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
function MOAIBox2DWorld:getPerformance() end

---@param p1x number
---@param p1y number
---@param p2x number
---@param p2y number
---@return boolean
---@return MOAIBox2DFixture
---@return number
---@return number
function MOAIBox2DWorld:getRayCast(p1x, p1y, p2x, p2y) end

---@return number
function MOAIBox2DWorld:getTimeToSleep() end

---@param angularSleepTolerance number
function MOAIBox2DWorld:setAngularSleepTolerance(angularSleepTolerance) end

---@param autoClearForces boolean
function MOAIBox2DWorld:setAutoClearForces(autoClearForces) end

---@param enable boolean
function MOAIBox2DWorld:setDebugDrawEnabled(enable) end

---@param flags number
function MOAIBox2DWorld:setDebugDrawFlags(flags) end

---@param gravityX number
---@param gravityY number
function MOAIBox2DWorld:setGravity(gravityX, gravityY) end

---@param velocityIteratons number
---@param positionIterations number
function MOAIBox2DWorld:setIterations(velocityIteratons, positionIterations) end

---@param linearSleepTolerance number
function MOAIBox2DWorld:setLinearSleepTolerance(linearSleepTolerance) end

---@param timeToSleep number
function MOAIBox2DWorld:setTimeToSleep(timeToSleep) end

---@param unitsToMeters number
function MOAIBox2DWorld:setUnitsToMeters(unitsToMeters) end


---@class MOAIBrowserAndroid
MOAIBrowserAndroid = { }

---@param url string
---@return boolean
function MOAIBrowserAndroid.canOpenURL(url) end

---@param url string
function MOAIBrowserAndroid.openURL(url) end

---@param url string
---@param params table
function MOAIBrowserAndroid.openURLWithParams(url, params) end


---@class MOAIButtonSensor
MOAIButtonSensor = { }

---@return boolean
function MOAIButtonSensor:down() end

---@return boolean
function MOAIButtonSensor:isDown() end

---@return boolean
function MOAIButtonSensor:isUp() end

---@param callback function
function MOAIButtonSensor:setCallback(callback) end

---@return boolean
function MOAIButtonSensor:up() end


---@class MOAIByteStream
MOAIByteStream = { }

function MOAIByteStream:close() end

---@param buffer string
function MOAIByteStream:open(buffer) end


---@class MOAICamera
MOAICamera = { }

---@return number
function MOAICamera:getFarPlane() end

---@return number
function MOAICamera:getFieldOfView() end

---@param x number
---@param y number
---@return number
---@return number
function MOAICamera:getFloorMove(x, y) end

---@param width number
---@return number
function MOAICamera:getFocalLength(width) end

---@return number
function MOAICamera:getNearPlane() end

---@return number
---@return number
---@return number
function MOAICamera:getViewVector() end

---@param x number
---@param y number
---@param z number
function MOAICamera:lookAt(x, y, z) end

---@param fov number
---@param delay number
function MOAICamera:moveFieldOfView(fov, delay) end

---@param fov number
---@param delay number
function MOAICamera:seekFieldOfView(fov, delay) end

---@param far number
function MOAICamera:setFarPlane(far) end

---@param hfow number
function MOAICamera:setFieldOfView(hfow) end

---@param near number
function MOAICamera:setNearPlane(near) end

---@param ortho boolean
function MOAICamera:setOrtho(ortho) end

---@param type number
function MOAICamera:setType(type) end


---@class MOAICameraAnchor2D
MOAICameraAnchor2D = { }

---@param parent MOAINode
function MOAICameraAnchor2D:setParent(parent) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAICameraAnchor2D:setRect(xMin, yMin, xMax, yMax) end


---@class MOAICameraFitter2D
MOAICameraFitter2D = { }

function MOAICameraFitter2D:clearAnchors() end

---@param mask number
function MOAICameraFitter2D:clearFitMode(mask) end

---@return number
function MOAICameraFitter2D:getFitDistance() end

---@return number
---@return number
function MOAICameraFitter2D:getFitLoc() end

---@return number
function MOAICameraFitter2D:getFitMode() end

---@return number
function MOAICameraFitter2D:getFitScale() end

---@return number
---@return number
function MOAICameraFitter2D:getTargetLoc() end

---@return number
function MOAICameraFitter2D:getTargetScale() end

---@param anchor MOAICameraAnchor2D
function MOAICameraFitter2D:insertAnchor(anchor) end

---@param anchor MOAICameraAnchor2D
function MOAICameraFitter2D:removeAnchor(anchor) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAICameraFitter2D:setBounds(xMin, yMin, xMax, yMax) end

---@param camera MOAITransform
function MOAICameraFitter2D:setCamera(camera) end

---@param damper number
function MOAICameraFitter2D:setDamper(damper) end

---@param x number
---@param y number
---@param snap boolean
function MOAICameraFitter2D:setFitLoc(x, y, snap) end

---@param mask number
function MOAICameraFitter2D:setFitMode(mask) end

---@param scale number
---@param snap boolean
function MOAICameraFitter2D:setFitScale(scale, snap) end

---@param min number
function MOAICameraFitter2D:setMin(min) end

---@param viewport MOAIViewport
function MOAICameraFitter2D:setViewport(viewport) end

function MOAICameraFitter2D:snapToTarget() end

---@param node MOAITransform
function MOAICameraFitter2D:startTrackingNode(node) end

function MOAICameraFitter2D:stopTrackingNode() end


---@class MOAIColor
MOAIColor = { }

---@param self MOAIProp
---@return number
---@return number
---@return number
---@return number
function MOAIColor.getColor(self) end

---@param rDelta number
---@param gDelta number
---@param bDelta number
---@param aDelta number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAIColor:moveColor(rDelta, gDelta, bDelta, aDelta, length, mode) end

---@param rGoal number
---@param gGoal number
---@param bGoal number
---@param aGoal number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAIColor:seekColor(rGoal, gGoal, bGoal, aGoal, length, mode) end

---@param r number
---@param g number
---@param b number
---@param a number
function MOAIColor:setColor(r, g, b, a) end

---@param parent MOAINode
function MOAIColor:setParent(parent) end


---@class MOAICompassSensor
MOAICompassSensor = { }

---@return number
function MOAICompassSensor:getHeading() end

---@param callback function
function MOAICompassSensor:setCallback(callback) end


---@class MOAICoroutine
MOAICoroutine = { }

---@param blocker MOAIAction
function MOAICoroutine.blockOnAction(blocker) end

---@return MOAICoroutine
function MOAICoroutine.currentThread() end

---@param threadFunc function
---@param parameters ...
function MOAICoroutine:run(threadFunc, parameters) end

---@param coroutine MOAICoroutine
function MOAICoroutine.setDefaultParent(coroutine) end

---@param coroutine MOAICoroutine
function MOAICoroutine.step(coroutine) end


---@class MOAIDataBuffer
MOAIDataBuffer = { }

---@param data string
---@return string
function MOAIDataBuffer:base64Decode(data) end

---@param data string
---@return string
function MOAIDataBuffer:base64Encode(data) end

function MOAIDataBuffer:clear() end

---@param data string
---@param level number
---@param windowBits number
---@return string
function MOAIDataBuffer.deflate(data, level, windowBits) end

---@return number
function MOAIDataBuffer:getSize() end

---@return string
function MOAIDataBuffer:getString() end

---@param data string
---@return string
function MOAIDataBuffer:hexDecode(data) end

---@param data string
---@return string
function MOAIDataBuffer:hexEncode(data) end

---@param data string
---@param windowBits number
---@return string
function MOAIDataBuffer.inflate(data, windowBits) end

---@param filename string
---@param detectZip number
---@param windowBits number
---@return boolean
function MOAIDataBuffer:load(filename, detectZip, windowBits) end

---@param filename string
---@param queue MOAITaskQueue
---@param callback function
---@param detectZip number
---@param inflateAsync boolean
---@param windowBits number
function MOAIDataBuffer:loadAsync(filename, queue, callback, detectZip, inflateAsync, windowBits) end

---@param filename string
---@return boolean
function MOAIDataBuffer:save(filename) end

---@param filename string
---@param queue MOAITaskQueue
---@param callback function
function MOAIDataBuffer:saveAsync(filename, queue, callback) end

---@param data string
function MOAIDataBuffer:setString(data) end

---@param data string
---@param name string
---@param columns number
---@return string
function MOAIDataBuffer.toCppHeader(data, name, columns) end


---@class MOAIDataBufferStream
MOAIDataBufferStream = { }

function MOAIDataBufferStream:close() end

---@param buffer MOAIDataBuffer
---@return boolean
function MOAIDataBufferStream:open(buffer) end


---@class MOAIDeck
MOAIDeck = { }

---@param idx number
---@return xMin
---@return yMin
---@return zMin
---@return xMax
---@return yMax
---@return zMax
function MOAIDeck.getBounds(idx) end


---@class MOAIDeckPropBase
MOAIDeckPropBase = { }

---@return MOAIDeck
function MOAIDeckPropBase:getDeck() end

---@param deck MOAIDeck
function MOAIDeckPropBase:setDeck(deck) end


---@class MOAIDeckRemapper
MOAIDeckRemapper = { }

---@param size number
function MOAIDeckRemapper:reserve(size) end

---@param base number
function MOAIDeckRemapper:setBase(base) end

---@param index number
---@param remap number
function MOAIDeckRemapper:setRemap(index, remap) end


---@class MOAIDialogAndroid
MOAIDialogAndroid = { }

---@param title string
---@param message string
---@param positive string
---@param neutral string
---@param negative string
---@param cancelable boolean
---@param callback function
function MOAIDialogAndroid.showDialog(title, message, positive, neutral, negative, cancelable, callback) end


---@class MOAIDialogIOS
MOAIDialogIOS = { }

---@param title string
---@param message string
---@param positive string
---@param neutral string
---@param negative string
---@param cancelable bool
---@param callback function
function MOAIDialogIOS.showDialog(title, message, positive, neutral, negative, cancelable, callback) end


---@class MOAIDraw
MOAIDraw = { }

---@param x0 number
---@param y0 number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
function MOAIDraw.drawBezierCurve(x0, y0, x1, y1, x2, y2, x3, y3) end

---@param x0 number
---@param y0 number
---@param z0 number
---@param x1 number
---@param y1 number
---@param z1 number
function MOAIDraw.drawBoxOutline(x0, y0, z0, x1, y1, z1) end

---@param x number
---@param y number
---@param r number
---@param steps number
function MOAIDraw.drawCircle(x, y, r, steps) end

---@param x number
---@param y number
---@param r number
---@param steps number
function MOAIDraw.drawCircleSpokes(x, y, r, steps) end

---@param vtxBuffer ...
---@param format ...
---@param count number
function MOAIDraw.drawElements(vtxBuffer, format, count) end

---@param x number
---@param y number
---@param xRad number
---@param yRad number
---@param steps number
function MOAIDraw.drawEllipse(x, y, xRad, yRad, steps) end

---@param x number
---@param y number
---@param xRad number
---@param yRad number
---@param steps number
function MOAIDraw.drawEllipseSpokes(x, y, xRad, yRad, steps) end

---@param vertices ...
function MOAIDraw.drawLine(vertices) end

---@param vertices ...
function MOAIDraw.drawPoints(vertices) end

---@param x number
---@param y number
---@param dx number
---@param dy number
function MOAIDraw.drawRay(x, y, dx, dy) end

---@param x0 number
---@param y0 number
---@param x1 number
---@param y1 number
function MOAIDraw.drawRect(x0, y0, x1, y1) end

---@param font MOAIFont
---@param size number
---@param text string
---@param x number
---@param y number
---@param scale number
---@param shadowOffsetX number
---@param shadowOffsetY number
function MOAIDraw.drawText(font, size, text, x, y, scale, shadowOffsetX, shadowOffsetY) end

---@param x0 number
---@param y0 number
---@param x1 number
---@param y1 number
---@param texture MOAITexture
function MOAIDraw.drawTexture(x0, y0, x1, y1, texture) end

---@param x number
---@param y number
---@param r number
---@param steps number
function MOAIDraw.fillCircle(x, y, r, steps) end

---@param x number
---@param y number
---@param xRad number
---@param yRad number
---@param steps number
function MOAIDraw.fillEllipse(x, y, xRad, yRad, steps) end

---@param vertices ...
function MOAIDraw.fillFan(vertices) end

---@param x0 number
---@param y0 number
---@param x1 number
---@param y1 number
function MOAIDraw.fillRect(x0, y0, x1, y1) end

---@param srcFactor number
---@param dstFactor number
---@param equation number
function MOAIDraw.setBlendMode(srcFactor, dstFactor, equation) end

---@param texture MOAITexture
---@return MOAITexture
function MOAIDraw.setDefaultTexture(texture) end

---@param r number
---@param g number
---@param b number
---@param a number
function MOAIDraw.setPenColor(r, g, b, a) end

---@param width number
function MOAIDraw.setPenWidth(width) end


---@class MOAIDrawDeck
MOAIDrawDeck = { }

---@param callback function
function MOAIDrawDeck:setBoundsCallback(callback) end

---@param callback function
function MOAIDrawDeck:setDrawCallback(callback) end


---@class MOAIDynamicGlyphCache
MOAIDynamicGlyphCache = { }

---@param colorFmt number
function MOAIDynamicGlyphCache:setColorFormat(colorFmt) end

---@param hPad number
---@param vPad number
function MOAIDynamicGlyphCache:setPadding(hPad, vPad) end


---@class MOAIEaseDriver
MOAIEaseDriver = { }

---@param nLinks number
function MOAIEaseDriver:reserveLinks(nLinks) end

---@param idx number
---@param target MOAINode
---@param attrID number
---@param value number
---@param mode number
function MOAIEaseDriver:setLink(idx, target, attrID, value, mode) end


---@class MOAIEaseType
MOAIEaseType = { }


---@class MOAIEnvironment
MOAIEnvironment = { }

---@return string
function MOAIEnvironment.generateGUID() end

---@return string
function MOAIEnvironment.getMACAddress() end

---@param key string
---@param value variant
function MOAIEnvironment.setValue(key, value) end


---@class MOAIEventSource
MOAIEventSource = { }


---@class MOAIFancyGrid
MOAIFancyGrid = { }

---@param value number
function MOAIFancyGrid:fillColor(value) end

---@param xTile number
---@param yTile number
---@return number
function MOAIFancyGrid:getColor(xTile, yTile) end

---@param xTile number
---@param yTile number
---@param value number
function MOAIFancyGrid:setColor(xTile, yTile, value) end


---@class MOAIFileStream
MOAIFileStream = { }

function MOAIFileStream:close() end

---@param fileName string
---@param mode number
---@return boolean
function MOAIFileStream:open(fileName, mode) end


---@class MOAIFileSystem
MOAIFileSystem = { }

---@param path string
function MOAIFileSystem.affirmPath(path) end

---@param filename string
---@return boolean
function MOAIFileSystem.checkFileExists(filename) end

---@param path string
---@return boolean
function MOAIFileSystem.checkPathExists(path) end

---@param srcPath string
---@param destPath string
---@return boolean
function MOAIFileSystem.copy(srcPath, destPath) end

---@param path string
---@param recursive boolean
---@return boolean
function MOAIFileSystem.deleteDirectory(path, recursive) end

---@param filename string
---@return boolean
function MOAIFileSystem.deleteFile(filename) end

---@param path string
---@return string
function MOAIFileSystem.getAbsoluteDirectoryPath(path) end

---@param filename string
---@return string
function MOAIFileSystem.getAbsoluteFilePath(filename) end

---@param path string
---@param base string
---@return string
function MOAIFileSystem.getRelativePath(path, base) end

---@param path string
---@param offsetToHeader string
---@param uncompressedSize number
---@param compressedSize number
---@return string
---@return string
function MOAIFileSystem.getVirtualPathInfo(path, offsetToHeader, uncompressedSize, compressedSize) end

---@return string
function MOAIFileSystem.getWorkingDirectory() end

---@param path string
---@return table
function MOAIFileSystem.listDirectories(path) end

---@param path string
---@return table
function MOAIFileSystem.listFiles(path) end

---@param filename string
---@return string
function MOAIFileSystem.loadFile(filename) end

---@param path string
---@param archive string
---@return boolean
function MOAIFileSystem.mountVirtualDirectory(path, archive) end

---@param oldPath string
---@param newPath string
---@return boolean
function MOAIFileSystem.rename(oldPath, newPath) end

---@param filename string
---@param contents string
function MOAIFileSystem.saveFile(filename, contents) end

---@param path string
---@return boolean
function MOAIFileSystem.setWorkingDirectory(path) end

---@param infilename string
---@param outfilename string
---@return boolean
function MOAIFileSystem.stripPKZipTimestamps(infilename, outfilename) end


---@class MOAIFont
MOAIFont = { }

---@return MOAILuaObject
function MOAIFont:getCache() end

---@return number
function MOAIFont:getDefaultSize() end

---@return string
function MOAIFont:getFilename() end

---@return number
function MOAIFont:getFlags() end

---@return MOAIImage
function MOAIFont:getImage() end

---@return MOAILuaObject
function MOAIFont:getReader() end

---@param filename string
function MOAIFont:load(filename) end

---@param filename string
---@param textures table
function MOAIFont:loadFromBMFont(filename, textures) end

---@param filename string
---@param charcodes string
---@param points number
---@param dpi number
function MOAIFont:loadFromTTF(filename, charcodes, points, dpi) end

---@param charCodes string
---@param points number
---@param dpi number
function MOAIFont:preloadGlyphs(charCodes, points, dpi) end

function MOAIFont:rebuildKerningTables() end

---@param cache MOAIGlyphCache
function MOAIFont:setCache(cache) end

---@param points number
---@param dpi number
function MOAIFont:setDefaultSize(points, dpi) end

---@param minFilter number
---@return number
---@return MOAILuaObject
function MOAIFont:setFilter(minFilter) end

---@param flags number
function MOAIFont:setFlags(flags) end

---@param image MOAIImage
function MOAIFont:setImage(image) end

---@param reader MOAIFontReader
function MOAIFont:setReader(reader) end

---@param shader MOAIShader
---@return MOAIShader
function MOAIFont:setShader(shader) end


---@class MOAIFoo
MOAIFoo = { }

function MOAIFoo.classHello() end

function MOAIFoo:instanceHello() end


---@class MOAIFooMgr
MOAIFooMgr = { }

function MOAIFooMgr.singletonHello() end


---@class MOAIFrameBuffer
MOAIFrameBuffer = { }

---@param discard boolean
---@return MOAIImage
function MOAIFrameBuffer:getGrabbedImage(discard) end

---@param image MOAIImage
---@param callback function
function MOAIFrameBuffer:grabNextFrame(image, callback) end

---@return table
function MOAIFrameBuffer:isPendingGrab() end


---@class MOAIFrameBufferTexture
MOAIFrameBufferTexture = { }

---@param width number
---@param height number
---@param colorFormat number
---@param depthFormat number
---@param stencilFormat number
function MOAIFrameBufferTexture:init(width, height, colorFormat, depthFormat, stencilFormat) end


---@class MOAIGeometryWriter
MOAIGeometryWriter = { }

---@param format MOAIVertexFormat
---@param vtxStream MOAIStream
---@param color ZLColorVec
---@param length number
---@param blendMode number
function MOAIGeometryWriter.applyColor(format, vtxStream, color, length, blendMode) end

---@param format MOAIVertexFormat
---@param vtxStream MOAIStream
---@param image MOAIImage
---@param length number
---@param blendMode number
---@param a0 number
---@param a1 number
---@param x0 number
---@param y0 number
---@param z0 number
---@param x1 number
---@param y1 number
---@param z1 number
function MOAIGeometryWriter.applyLightFromImage(format, vtxStream, image, length, blendMode, a0, a1, x0, y0, z0, x1, y1, z1) end

---@param format MOAIVertexFormat
---@param vtxStream MOAIStream
---@param length number
---@param x0 number
---@param y0 number
---@param z0 number
---@param x1 number
---@param y1 number
---@param z1 number
---@param r0 number
---@param g0 number
---@param b0 number
---@param a0 number
---@param r1 number
---@param g1 number
---@param b1 number
---@param a1 number
---@param cap0 boolean
---@param cap1 boolean
---@param blendMode number
function MOAIGeometryWriter.applyLinearGradient(format, vtxStream, length, x0, y0, z0, x1, y1, z1, r0, g0, b0, a0, r1, g1, b1, a1, cap0, cap1, blendMode) end

---@param format MOAIVertexFormat
---@param vtxStream MOAIStream
---@param vtxStreamLength number
---@param idxStream MOAIStream
---@param idxStreamLength number
---@param vtxBuffer MOAIVertexBuffer
---@param idxBuffer MOAIIndexBuffer
---@param idxSizeInBytes number
---@return number
function MOAIGeometryWriter.getMesh(format, vtxStream, vtxStreamLength, idxStream, idxStreamLength, vtxBuffer, idxBuffer, idxSizeInBytes) end

---@param format MOAIVertexFormat
---@param vtxStream MOAIStream
---@param idxStream MOAIStream
function MOAIGeometryWriter.pruneVertices(format, vtxStream, idxStream) end

---@param format MOAIVertexFormat
---@param vtxStream MOAIStream
---@param xSnap number
---@param length number
---@param ySnap number
---@param zSnap number
function MOAIGeometryWriter.snapCoords(format, vtxStream, xSnap, length, ySnap, zSnap) end

---@param format MOAIVertexFormat
---@param vtxStream MOAIStream
---@param xMin number
---@param yMin number
---@param zMin number
---@param xMax number
---@param yMax number
---@param zMax number
function MOAIGeometryWriter.writeBox(format, vtxStream, xMin, yMin, zMin, xMax, yMax, zMax) end

---@param format MOAIVertexFormat
---@param vtxStream MOAIStream
---@param size number
---@param x number
---@param y number
---@param z number
function MOAIGeometryWriter.writeCube(format, vtxStream, size, x, y, z) end


---@class MOAIGfxBuffer
MOAIGfxBuffer = { }

---@param stream MOAIStream
---@param length number
function MOAIGfxBuffer:copyFromStream(stream, length) end

function MOAIGfxBuffer:release() end

---@param size number
function MOAIGfxBuffer:reserve(size) end

---@param count number
function MOAIGfxBuffer:reserveVBOs(count) end

function MOAIGfxBuffer:scheduleFlush() end


---@class MOAIGfxMgr
MOAIGfxMgr = { }

---@return MOAIFrameBuffer
function MOAIGfxMgr.getFrameBuffer() end

---@return number
function MOAIGfxMgr.getMaxTextureSize() end

---@return number
function MOAIGfxMgr.getMaxTextureUnits() end

---@return number
---@return number
function MOAIGfxMgr.getViewSize() end

---@param age number
function MOAIGfxMgr.purgeResources(age) end

function MOAIGfxMgr.renewResources() end


---@class MOAIGfxResource
MOAIGfxResource = { }

---@return number
function MOAIGfxResource:getAge() end

---@param age number
---@return boolean
function MOAIGfxResource:purge(age) end

---@param reloader function
function MOAIGfxResource:setReloader(reloader) end


---@class MOAIGlobalEventSource
MOAIGlobalEventSource = { }


---@class MOAIGlyphCache
MOAIGlyphCache = { }


---@class MOAIGraphicsPropBase
MOAIGraphicsPropBase = { }

---@return boolean
function MOAIGraphicsPropBase:isVisible() end

---@param billboard boolean
---@param mode number
function MOAIGraphicsPropBase:setBillboard(billboard, mode) end

---@param parent MOAINode
function MOAIGraphicsPropBase:setParent(parent) end

---@param scissorRect MOAIScissorRect
function MOAIGraphicsPropBase:setScissorRect(scissorRect) end

---@param transform MOAITransformBase
function MOAIGraphicsPropBase:setUVTransform(transform) end

---@param visible boolean
function MOAIGraphicsPropBase:setVisible(visible) end


---@class MOAIGrid
MOAIGrid = { }

---@param xTile number
---@param yTile number
---@param mask number
function MOAIGrid:clearTileFlags(xTile, yTile, mask) end

---@param value number
function MOAIGrid:fill(value) end

---@param xTile number
---@param yTile number
---@return number
function MOAIGrid:getTile(xTile, yTile) end

---@param xTile number
---@param yTile number
---@param mask number
---@return number
function MOAIGrid:getTileFlags(xTile, yTile, mask) end

---@param row number
---@param values ...
function MOAIGrid:setRow(row, values) end

---@param xTile number
---@param yTile number
---@param value number
function MOAIGrid:setTile(xTile, yTile, value) end

---@param xTile number
---@param yTile number
---@param mask number
function MOAIGrid:setTileFlags(xTile, yTile, mask) end

---@param stream MOAIStream
---@return number
function MOAIGrid:streamTilesIn(stream) end

---@param stream MOAIStream
---@return number
function MOAIGrid:streamTilesOut(stream) end

---@param xTile number
---@param yTile number
---@param mask number
function MOAIGrid:toggleTileFlags(xTile, yTile, mask) end


---@class MOAIGridPathGraph
MOAIGridPathGraph = { }

---@param grid MOAIGrid
function MOAIGridPathGraph:setGrid(grid) end


---@class MOAIGridPropBase
MOAIGridPropBase = { }

---@return MOAIGrid
function MOAIGridPropBase:getGrid() end

---@param grid MOAIGrid
function MOAIGridPropBase:setGrid(grid) end

---@param xScale number
---@param yScale number
function MOAIGridPropBase:setGridScale(xScale, yScale) end


---@class MOAIGridSpace
MOAIGridSpace = { }

---@param cellAddr number
---@return number
---@return number
function MOAIGridSpace:cellAddrToCoord(cellAddr) end

---@param xTile number
---@param yTile number
---@return number
function MOAIGridSpace:getCellAddr(xTile, yTile) end

---@return number
---@return number
function MOAIGridSpace:getCellSize() end

---@return number
---@return number
function MOAIGridSpace:getOffset() end

---@return number
---@return number
function MOAIGridSpace:getSize() end

---@param xTile number
---@param yTile number
---@param position number
---@return number
---@return number
function MOAIGridSpace:getTileLoc(xTile, yTile, position) end

---@return number
---@return number
function MOAIGridSpace:getTileSize() end

---@param width number
---@param height number
---@param tileWidth number
---@param tileHeight number
---@param xGutter number
---@param yGutter number
function MOAIGridSpace:initAxialHexGrid(width, height, tileWidth, tileHeight, xGutter, yGutter) end

---@param width number
---@param height number
---@param tileWidth number
---@param tileHeight number
---@param xGutter number
---@param yGutter number
function MOAIGridSpace:initDiamondGrid(width, height, tileWidth, tileHeight, xGutter, yGutter) end

---@param width number
---@param height number
---@param radius number
---@param xGutter number
---@param yGutter number
function MOAIGridSpace:initHexGrid(width, height, radius, xGutter, yGutter) end

---@param width number
---@param height number
---@param tileWidth number
---@param tileHeight number
---@param xGutter number
---@param yGutter number
function MOAIGridSpace:initObliqueGrid(width, height, tileWidth, tileHeight, xGutter, yGutter) end

---@param width number
---@param height number
---@param tileWidth number
---@param tileHeight number
---@param xGutter number
---@param yGutter number
function MOAIGridSpace:initRectGrid(width, height, tileWidth, tileHeight, xGutter, yGutter) end

---@param x number
---@param y number
---@return number
function MOAIGridSpace:locToCellAddr(x, y) end

---@param x number
---@param y number
---@return number
---@return number
function MOAIGridSpace:locToCoord(x, y) end

---@param repeatX boolean
---@param repeatY boolean
function MOAIGridSpace:setRepeat(repeatX, repeatY) end

---@param shape number
function MOAIGridSpace:setShape(shape) end

---@param width number
---@param height number
---@param cellWidth number
---@param cellHeight number
---@param xOff number
---@param yOff number
---@param tileWidth number
---@param tileHeight number
function MOAIGridSpace:setSize(width, height, cellWidth, cellHeight, xOff, yOff, tileWidth, tileHeight) end

---@param xTile number
---@param yTile number
---@return number
---@return number
function MOAIGridSpace:wrapCoord(xTile, yTile) end


---@class MOAIHashWriter
MOAIHashWriter = { }

---@return number
function MOAIHashWriter:getChecksum() end

---@return string
function MOAIHashWriter:getHash() end

---@return string
function MOAIHashWriter:getHashBase64() end

---@return string
function MOAIHashWriter:getHashHex() end

---@param target MOAIStream
---@return boolean
function MOAIHashWriter:openAdler32(target) end

---@param target MOAIStream
---@return boolean
function MOAIHashWriter:openCRC32(target) end

---@param target MOAIStream
---@return boolean
function MOAIHashWriter:openCRC32b(target) end

---@param target MOAIStream
---@return boolean
function MOAIHashWriter:openWhirlpool(target) end

---@param hmac string
function MOAIHashWriter:setHMACKey(hmac) end


---@class MOAIHashWriterCrypto
MOAIHashWriterCrypto = { }

---@param self MOAIStreamWriter
---@param target MOAIStream
---@return boolean
function MOAIHashWriterCrypto.openMD5(self, target) end

---@param self MOAIStreamWriter
---@param target MOAIStream
---@return boolean
function MOAIHashWriterCrypto.openSHA1(self, target) end

---@param self MOAIStreamWriter
---@param target MOAIStream
---@return boolean
function MOAIHashWriterCrypto.openSHA224(self, target) end

---@param self MOAIStreamWriter
---@param target MOAIStream
---@return boolean
function MOAIHashWriterCrypto.openSHA256(self, target) end

---@param self MOAIStreamWriter
---@param target MOAIStream
---@return boolean
function MOAIHashWriterCrypto.openSHA384(self, target) end

---@param self MOAIStreamWriter
---@param target MOAIStream
---@return boolean
function MOAIHashWriterCrypto.openSHA512(self, target) end


---@class MOAIHttpTaskBase
MOAIHttpTaskBase = { }

---@return number
function MOAIHttpTaskBase:getProgress() end

---@return number
function MOAIHttpTaskBase:getResponseCode() end

---@param header string
---@return string
function MOAIHttpTaskBase:getResponseHeader(header) end

---@return number
function MOAIHttpTaskBase:getSize() end

---@return string
function MOAIHttpTaskBase:getString() end

---@param url string
---@param useragent string
---@param verbose boolean
---@param blocking boolean
function MOAIHttpTaskBase:httpGet(url, useragent, verbose, blocking) end

---@param url string
---@param data string
---@param useragent string
---@param verbose boolean
---@param blocking boolean
function MOAIHttpTaskBase:httpPost(url, data, useragent, verbose, blocking) end

---@return boolean
function MOAIHttpTaskBase:isBusy() end

---@return MOAIXmlParser
function MOAIHttpTaskBase:parseXml() end

function MOAIHttpTaskBase:performAsync() end

function MOAIHttpTaskBase:performSync() end

---@param data string
function MOAIHttpTaskBase:setBody(data) end

---@param callback function
function MOAIHttpTaskBase:setCallback(callback) end

---@param filename string
function MOAIHttpTaskBase:setCookieDst(filename) end

---@param filename string
function MOAIHttpTaskBase:setCookieSrc(filename) end

---@param enable boolean
function MOAIHttpTaskBase:setFailOnError(enable) end

---@param follow boolean
function MOAIHttpTaskBase:setFollowRedirects(follow) end

---@param key string
---@param value string
function MOAIHttpTaskBase:setHeader(key, value) end

---@param verifyPeer boolean
---@param verifyHost boolean
---@param path string
function MOAIHttpTaskBase:setSSLOptions(verifyPeer, verifyHost, path) end

---@param stream MOAIStream
function MOAIHttpTaskBase:setStream(stream) end

---@param timeout number
function MOAIHttpTaskBase:setTimeout(timeout) end

---@param url string
function MOAIHttpTaskBase:setUrl(url) end

---@param useragent string
function MOAIHttpTaskBase:setUserAgent(useragent) end

---@param verb number
function MOAIHttpTaskBase:setVerb(verb) end

---@param verbose boolean
function MOAIHttpTaskBase:setVerbose(verbose) end


---@class MOAIHttpTaskNaCl
MOAIHttpTaskNaCl = { }


---@class MOAIHttpTaskNSURL
MOAIHttpTaskNSURL = { }


---@class MOAIImage
MOAIImage = { }

---@return number
---@return number
---@return number
---@return number
function MOAIImage:average() end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAIImage:bleedRect(xMin, yMin, xMax, yMax) end

---@param radius number
---@param sigma number
function MOAIImage:calculateGaussianKernel(radius, sigma) end

---@param other MOAIImage
---@return boolean
function MOAIImage:compare(other) end

---@param colorFmt number
---@param pixelFmt number
---@return MOAIImage
function MOAIImage:convert(colorFmt, pixelFmt) end

---@param kernel table
---@param normalize boolean
---@return MOAIImage
function MOAIImage:convolve(kernel, normalize) end

---@param kernel table
---@param horizontal boolean
---@param normalize boolean
---@return MOAIImage
function MOAIImage:convolve1D(kernel, horizontal, normalize) end

---@return MOAIImage
function MOAIImage:copy() end

---@param source MOAIImage
---@param srcX number
---@param srcY number
---@param destX number
---@param destY number
---@param width number
---@param height number
function MOAIImage:copyBits(source, srcX, srcY, destX, destY, width, height) end

---@param source MOAIImage
---@param srcXMin number
---@param srcYMin number
---@param srcXMax number
---@param srcYMax number
---@param destXMin number
---@param destYMin number
---@param destXMax number
---@param destYMax number
---@param filter number
---@param srcFactor number
---@param dstFactor number
---@param equation number
function MOAIImage:copyRect(source, srcXMin, srcYMin, srcXMax, srcYMax, destXMin, destYMin, destXMax, destYMax, filter, srcFactor, dstFactor, equation) end

---@param Optional. rY
---@param Optional. gY
---@param Optional. bY
---@param Optional. K
function MOAIImage:desaturate(rY, gY, bY, K) end

---@param x number
---@param y number
---@param radius number
---@param r number
---@param g number
---@param b number
---@param a number
function MOAIImage.fillCircle(x, y, radius, r, g, b, a) end

---@param x number
---@param y number
---@param radiusX number
---@param radiusY number
---@param r number
---@param g number
---@param b number
---@param a number
function MOAIImage.fillEllipse(x, y, radiusX, radiusY, r, g, b, a) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
---@param r number
---@param g number
---@param b number
---@param a number
function MOAIImage:fillRect(xMin, yMin, xMax, yMax, r, g, b, a) end

---@param gamma number
function MOAIImage:gammaCorrection(gamma) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
---@param distMin number
---@param distMax number
---@param r number
---@param g number
---@param b number
---@param a number
function MOAIImage:generateOutlineFromSDF(xMin, yMin, xMax, yMax, distMin, distMax, r, g, b, a) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAIImage:generateSDF(xMin, yMin, xMax, yMax) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
---@param sizeInPixels number
function MOAIImage:generateSDFAA(xMin, yMin, xMax, yMax, sizeInPixels) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
---@param threshold number
function MOAIImage:generateSDFDeadReckoning(xMin, yMin, xMax, yMax, threshold) end

---@param x number
---@param y number
---@return number
function MOAIImage:getColor32(x, y) end

---@return rect
function MOAIImage:getContentRect() end

---@return byte
function MOAIImage:getData() end

---@return number
function MOAIImage:getFormat() end

---@param x number
---@param y number
---@return number
---@return number
---@return number
---@return number
function MOAIImage:getRGBA(x, y) end

---@param scale number
---@return number
---@return number
function MOAIImage:getSize(scale) end

---@param width number
---@param height number
---@param colorFmt number
function MOAIImage:init(width, height, colorFmt) end

---@return bool
function MOAIImage:isOpaque() end

---@param filename string
---@param transform number
function MOAIImage:load(filename, transform) end

---@param filename string
---@param queue MOAITaskQueue
---@param callback function
---@param transform number
function MOAIImage:loadAsync(filename, queue, callback, transform) end

---@param buffer MOAIDataBuffer
---@param transform number
function MOAIImage:loadFromBuffer(buffer, transform) end

---@param r1 number
---@param r2 number
---@param r3 number
---@param r4 number
---@param g1 number
---@param g2 number
---@param g3 number
---@param g4 number
---@param b1 number
---@param b2 number
---@param b3 number
---@param b4 number
---@param a1 number
---@param a2 number
---@param a3 number
---@param a4 number
---@param K number
function MOAIImage:mix(r1, r2, r3, r4, g1, g2, g3, g4, b1, b2, b3, b4, a1, a2, a3, a4, K) end

---@return MOAIImage
function MOAIImage:padToPow2() end

function MOAIImage:print() end

---@param width number
---@param height number
---@param filter number
---@return MOAIImage
function MOAIImage:resize(width, height, filter) end

---@param width number
---@param height number
---@return MOAIImage
function MOAIImage:resizeCanvas(width, height) end

---@param x number
---@param y number
---@param color number
function MOAIImage:setColor32(x, y, color) end

---@param x number
---@param y number
---@param r number
---@param g number
---@param b number
---@param a number
function MOAIImage:setRGBA(x, y, r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@param a number
function MOAIImage:simpleThreshold(r, g, b, a) end

---@param tileWidth number
---@param tileHeight number
---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAIImage.subdivideRect(tileWidth, tileHeight, xMin, yMin, xMax, yMax) end

---@param filename string
---@param format string
---@return boolean
function MOAIImage:write(filename, format) end


---@class MOAIImageTexture
MOAIImageTexture = { }

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAIImageTexture:updateRegion(xMin, yMin, xMax, yMax) end


---@class MOAIIndexBuffer
MOAIIndexBuffer = { }

---@param stream MOAIStream
---@param sourceSizeInBytes number
function MOAIIndexBuffer:copyFromStream(stream, sourceSizeInBytes) end

---@param primType number
---@return number
function MOAIIndexBuffer:countElements(primType) end

function MOAIIndexBuffer:printIndices() end

function MOAIIndexBuffer:setIndexSize() end


---@class MOAIInputDevice
MOAIInputDevice = { }

---@return string
function MOAIInputDevice:getHardwareInfo() end


---@class MOAIInputMgr
MOAIInputMgr = { }


---@class MOAIInstanceEventSource
MOAIInstanceEventSource = { }

---@param eventID number
---@return function
function MOAIInstanceEventSource:getListener(eventID) end

---@param eventID number
---@param callback function
function MOAIInstanceEventSource:setListener(eventID, callback) end


---@class MOAIJoystickSensor
MOAIJoystickSensor = { }

---@return number
---@return number
function MOAIJoystickSensor:getVector() end

---@param callback function
function MOAIJoystickSensor:setCallback(callback) end


---@class MOAIKeyboardAndroid
MOAIKeyboardAndroid = { }


---@class MOAIKeyboardIOS
MOAIKeyboardIOS = { }

---@return string
function MOAIKeyboardIOS.getText() end

function MOAIKeyboardIOS.hideKeyboard() end

---@param maxLength number
---@return 
function MOAIKeyboardIOS.setMaxLength(maxLength) end

---@param text string
---@param type number
---@param returnKey number
---@param secure boolean
---@param autocap number
---@param appearance number
function MOAIKeyboardIOS.showKeyboard(text, type, returnKey, secure, autocap, appearance) end


---@class MOAIKeyboardSensor
MOAIKeyboardSensor = { }

---@param keys ...
---@return boolean...
function MOAIKeyboardSensor:keyDown(keys) end

---@param keys ...
---@return boolean...
function MOAIKeyboardSensor:keyIsDown(keys) end

---@param keys ...
---@return boolean...
function MOAIKeyboardSensor:keyIsUp(keys) end

---@param keys ...
---@return boolean...
function MOAIKeyboardSensor:keyUp(keys) end

---@param callback function
function MOAIKeyboardSensor:setCallback(callback) end

---@param callback function
function MOAIKeyboardSensor:setCharCallback(callback) end

---@param callback function
function MOAIKeyboardSensor:setEditCallback(callback) end

---@param callback function
function MOAIKeyboardSensor:setKeyCallback(callback) end


---@class MOAIKeyCode
MOAIKeyCode = { }


---@class MOAILocationSensor
MOAILocationSensor = { }

---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
function MOAILocationSensor:getLocation() end

---@param callback function
function MOAILocationSensor:setCallback(callback) end


---@class MOAILogMgr
MOAILogMgr = { }

function MOAILogMgr.closeFile() end

---@return boolean
function MOAILogMgr.isDebugBuild() end

---@param message string
function MOAILogMgr.log(message) end

---@param filename string
function MOAILogMgr.openFile(filename) end

---@param logLevel number
function MOAILogMgr.setLogLevel(logLevel) end

---@param check boolean
function MOAILogMgr.setTypeCheckLuaParams(check) end


---@class MOAILuaUtil
MOAILuaUtil = { }

---@param bytecode string
---@return string
function MOAILuaUtil.convert(bytecode) end

---@param bytecode string
---@return table
function MOAILuaUtil.getHeader(bytecode) end


---@class MOAIMaterialBatch
MOAIMaterialBatch = { }

---@return number
function MOAIMaterialBatch:getIndexBatchSize() end

---@param count number
function MOAIMaterialBatch:reserveMaterials(count) end

---@param srcFactor number
---@param dstFactor number
function MOAIMaterialBatch:setBlendMode(srcFactor, dstFactor) end

---@param indexBatchSize number
function MOAIMaterialBatch:setIndexBatchSize(indexBatchSize) end


---@class MOAIMemStream
MOAIMemStream = { }

function MOAIMemStream:close() end

---@param reserve number
---@param chunkSize number
---@return boolean
function MOAIMemStream:open(reserve, chunkSize) end


---@class MOAIMesh
MOAIMesh = { }

---@param indexBuffer MOAIGfxBuffer
function MOAIMesh:setIndexBuffer(indexBuffer) end

---@param penWidth number
function MOAIMesh:setPenWidth(penWidth) end

---@param primType number
function MOAIMesh:setPrimType(primType) end


---@class MOAIMetaTileDeck2D
MOAIMetaTileDeck2D = { }

---@param nBrushes number
function MOAIMetaTileDeck2D:reserveMetaTiles(nBrushes) end

---@param deck MOAIDeck
function MOAIMetaTileDeck2D:setDeck(deck) end

---@param grid MOAIGrid
function MOAIMetaTileDeck2D:setGrid(grid) end

---@param idx number
---@param xTile number
---@param yTile number
---@param width number
---@param height number
---@param xOff number
---@param yOff number
function MOAIMetaTileDeck2D:setMetaTile(idx, xTile, yTile, width, height, xOff, yOff) end


---@class MOAIMotionSensor
MOAIMotionSensor = { }

---@return number
---@return number
---@return number
function MOAIMotionSensor:getLevel() end

---@param callback function
function MOAIMotionSensor:setCallback(callback) end


---@class MOAIMoviePlayerAndroid
MOAIMoviePlayerAndroid = { }

---@param url string
function MOAIMoviePlayerAndroid.init(url) end

function MOAIMoviePlayerAndroid.pause() end

function MOAIMoviePlayerAndroid.play() end

function MOAIMoviePlayerAndroid.stop() end


---@class MOAIMoviePlayerIOS
MOAIMoviePlayerIOS = { }

---@param url string
function MOAIMoviePlayerIOS.init(url) end

function MOAIMoviePlayerIOS.pause() end

function MOAIMoviePlayerIOS.play() end

function MOAIMoviePlayerIOS.stop() end


---@class MOAINode
MOAINode = { }

---@param attrID number
function MOAINode:clearAttrLink(attrID) end

---@param sourceNode MOAINode
function MOAINode:clearNodeLink(sourceNode) end

function MOAINode:forceUpdate() end

---@param attrID number
---@return number
function MOAINode:getAttr(attrID) end

---@param attrID number
---@return MOAINode
---@return number
function MOAINode:getAttrLink(attrID) end

---@return number
function MOAINode:getNodeState() end

---@param attrID number
---@param delta number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAINode:moveAttr(attrID, delta, length, mode) end

function MOAINode:scheduleUpdate() end

---@param attrID number
---@param goal number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAINode:seekAttr(attrID, goal, length, mode) end

---@param attrID number
---@param value number
function MOAINode:setAttr(attrID, value) end

---@param attrID number
---@param sourceNode MOAINode
---@param sourceAttrID number
function MOAINode:setAttrLink(attrID, sourceNode, sourceAttrID) end

---@param sourceNode MOAINode
function MOAINode:setNodeLink(sourceNode) end


---@class MOAINotificationsAndroid
MOAINotificationsAndroid = { }

---@return number
function MOAINotificationsAndroid.getAppIconBadgeNumber() end

---@param message string
---@param seconds number
function MOAINotificationsAndroid.localNotificationInSeconds(message, seconds) end

---@param sender string
function MOAINotificationsAndroid.registerForRemoteNotifications(sender) end

function MOAINotificationsAndroid.setAppIconBadgeNumber() end

function MOAINotificationsAndroid.unregisterForRemoteNotifications() end


---@class MOAINotificationsIOS
MOAINotificationsIOS = { }

---@return integer
function MOAINotificationsIOS.getAppIconBadgeNumber() end

---@param types integer
function MOAINotificationsIOS.registerForRemoteNotifications(types) end

---@param count integer
function MOAINotificationsIOS.setAppIconBadgeNumber(count) end

function MOAINotificationsIOS.unregisterForRemoteNotifications() end


---@class MOAIParticleCallbackPlugin
MOAIParticleCallbackPlugin = { }


---@class MOAIParticleDistanceEmitter
MOAIParticleDistanceEmitter = { }

function MOAIParticleDistanceEmitter:reset() end

---@param min number
---@param max number
function MOAIParticleDistanceEmitter:setDistance(min, max) end


---@class MOAIParticleEmitter
MOAIParticleEmitter = { }

---@param min number
---@param max number
function MOAIParticleEmitter:setAngle(min, max) end

---@param min number
---@param max number
function MOAIParticleEmitter:setEmission(min, max) end

---@param min number
---@param max number
function MOAIParticleEmitter:setMagnitude(min, max) end

---@param radius number
function MOAIParticleEmitter:setRadius(radius) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAIParticleEmitter:setRect(xMin, yMin, xMax, yMax) end

---@param state number
function MOAIParticleEmitter:setState(state) end

---@param system MOAIParticleSystem
function MOAIParticleEmitter:setSystem(system) end

---@param total number
function MOAIParticleEmitter:surge(total) end


---@class MOAIParticleForce
MOAIParticleForce = { }

---@param radius number
---@param magnitude number
function MOAIParticleForce:initAttractor(radius, magnitude) end

---@param radius number
---@param magnitude number
function MOAIParticleForce:initBasin(radius, magnitude) end

---@param x number
---@param y number
function MOAIParticleForce:initLinear(x, y) end

---@param magnitude number
function MOAIParticleForce:initRadial(magnitude) end

---@param type number
function MOAIParticleForce:setType(type) end


---@class MOAIParticlePlugin
MOAIParticlePlugin = { }

---@return number
function MOAIParticlePlugin:getSize() end


---@class MOAIParticleScript
MOAIParticleScript = { }

---@param r0 number
---@param v0 number
function MOAIParticleScript:abs(r0, v0) end

---@param r0 number
---@param v0 number
---@param v1 number
function MOAIParticleScript:add(r0, v0, v1) end

---@param r0 number
---@param r1 number
---@param v0 number
function MOAIParticleScript:angleVec(r0, r1, v0) end

---@param r0 number
---@param r1 number
---@param r2 number
---@param r3 number
function MOAIParticleScript:color(r0, r1, r2, r3) end

---@param r0 number
---@param v0 number
function MOAIParticleScript:cos(r0, v0) end

---@param r0 number
---@param v0 number
---@param v1 number
---@param v2 number
function MOAIParticleScript:cycle(r0, v0, v1, v2) end

---@param r0 number
---@param v0 number
---@param v1 number
function MOAIParticleScript:div(r0, v0, v1) end

---@param r0 number
---@param v0 number
---@param v1 number
---@param easeType number
function MOAIParticleScript:ease(r0, v0, v1, easeType) end

---@param r0 number
---@param v0 number
---@param v1 number
---@param easeType number
function MOAIParticleScript:easeDelta(r0, v0, v1, easeType) end

---@param r0 number
---@param v0 number
---@param v1 number
function MOAIParticleScript:mul(r0, v0, v1) end

---@param r0 number
---@param r1 number
---@param v0 number
---@param v1 number
function MOAIParticleScript:norm(r0, r1, v0, v1) end

---@param r0 number
---@param v0 number
function MOAIParticleScript:oscillate(r0, v0) end

---@param const number
---@return number
function MOAIParticleScript.packConst(const) end

---@param regIdx number
---@return number
function MOAIParticleScript.packLiveReg(regIdx) end

---@param regIdx number
---@return number
function MOAIParticleScript.packReg(regIdx) end

---@param r0 number
---@param v0 number
---@param v1 number
function MOAIParticleScript:rand(r0, v0, v1) end

---@param r0 number
---@param v0 number
---@param v1 number
function MOAIParticleScript:randInt(r0, v0, v1) end

---@param r0 number
---@param r1 number
---@param v0 number
---@param v1 number
function MOAIParticleScript:randVec(r0, r1, v0, v1) end

---@param r0 number
---@param v0 number
function MOAIParticleScript:set(r0, v0) end

---@param r0 number
---@param v0 number
function MOAIParticleScript:setLiveReg(r0, v0) end

---@param r0 number
---@param v0 number
function MOAIParticleScript:sin(r0, v0) end

function MOAIParticleScript:sprite() end

---@param r0 number
---@param v0 number
---@param v1 number
function MOAIParticleScript:step(r0, v0, v1) end

---@param r0 number
---@param v0 number
---@param v1 number
function MOAIParticleScript:sub(r0, v0, v1) end

---@param r0 number
---@param v0 number
function MOAIParticleScript:tan(r0, v0) end

---@param r0 number
function MOAIParticleScript:time(r0) end

---@param r0 number
---@param v0 number
---@param v1 number
function MOAIParticleScript:vecAngle(r0, v0, v1) end

---@param r0 number
---@param v0 number
---@param v1 number
---@param v2 number
function MOAIParticleScript:wrap(r0, v0, v1, v2) end


---@class MOAIParticleState
MOAIParticleState = { }

function MOAIParticleState:clearForces() end

---@param force MOAIParticleForce
function MOAIParticleState:pushForce(force) end

---@param damping number
function MOAIParticleState:setDamping(damping) end

---@param script MOAIParticleScript
function MOAIParticleState:setInitScript(script) end

---@param minMass number
---@param maxMass number
function MOAIParticleState:setMass(minMass, maxMass) end

---@param next MOAIParticleState
function MOAIParticleState:setNext(next) end

---@param plugin MOAIParticlePlugin
function MOAIParticleState:setPlugin(plugin) end

---@param script MOAIParticleScript
function MOAIParticleState:setRenderScript(script) end

---@param minTerm number
---@param maxTerm number
function MOAIParticleState:setTerm(minTerm, maxTerm) end


---@class MOAIParticleSystem
MOAIParticleSystem = { }

---@param cap boolean
function MOAIParticleSystem:capParticles(cap) end

---@param cap boolean
function MOAIParticleSystem:capSprites(cap) end

function MOAIParticleSystem:clearSprites() end

---@param index number
---@return MOAIParticleState
function MOAIParticleSystem:getState(index) end

---@return boolean
function MOAIParticleSystem:isIdle() end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param state number
---@return boolean
function MOAIParticleSystem:pushParticle(x, y, dx, dy, state) end

---@param x number
---@param y number
---@param rot number
---@param xScale number
---@param yScale number
---@return boolean
function MOAIParticleSystem:pushSprite(x, y, rot, xScale, yScale) end

---@param nParticles number
---@param particleSize number
function MOAIParticleSystem:reserveParticles(nParticles, particleSize) end

---@param nSprites number
function MOAIParticleSystem:reserveSprites(nSprites) end

---@param nStates number
function MOAIParticleSystem:reserveStates(nStates) end

---@param computBounds boolean
function MOAIParticleSystem:setComputeBounds(computBounds) end

---@param order number
function MOAIParticleSystem:setDrawOrder(order) end

---@param r number
---@param g number
---@param b number
---@param a number
function MOAIParticleSystem:setSpriteColor(r, g, b, a) end

---@param index number
function MOAIParticleSystem:setSpriteDeckIdx(index) end

---@param index number
---@param state MOAIParticleState
function MOAIParticleSystem:setState(index, state) end

---@param total number
---@param x number
---@param y number
---@param dx number
---@param dy number
function MOAIParticleSystem:surge(total, x, y, dx, dy) end


---@class MOAIParticleTimedEmitter
MOAIParticleTimedEmitter = { }

---@param min number
---@param max number
function MOAIParticleTimedEmitter:setFrequency(min, max) end


---@class MOAIPartition
MOAIPartition = { }

function MOAIPartition:clear() end

---@param x number
---@param y number
---@param z number
---@param sortMode number
---@param xScale number
---@param yScale number
---@param zScale number
---@param priorityScale number
---@param interfaceMask number
---@param queryMask number
---@return MOAIPartitionHull
function MOAIPartition:hullForPoint(x, y, z, sortMode, xScale, yScale, zScale, priorityScale, interfaceMask, queryMask) end

---@param x number
---@param y number
---@param z number
---@param xdirection number
---@param ydirection number
---@param zdirection number
---@param interfaceMask number
---@param queryMask number
---@return MOAIPartitionHull
function MOAIPartition:hullForRay(x, y, z, xdirection, ydirection, zdirection, interfaceMask, queryMask) end

---@param sortMode number
---@param xScale number
---@param yScale number
---@param zScale number
---@param priorityScale number
---@param interfaceMask number
---@param queryMask number
---@return ...
function MOAIPartition:hullList(sortMode, xScale, yScale, zScale, priorityScale, interfaceMask, queryMask) end

---@param x number
---@param y number
---@param z number
---@param sortMode number
---@param xScale number
---@param yScale number
---@param zScale number
---@param priorityScale number
---@param interfaceMask number
---@param queryMask number
---@return ...
function MOAIPartition:hullListForPoint(x, y, z, sortMode, xScale, yScale, zScale, priorityScale, interfaceMask, queryMask) end

---@param x number
---@param y number
---@param z number
---@param xdirection number
---@param ydirection number
---@param zdirection number
---@param sortMode number
---@param xScale number
---@param yScale number
---@param zScale number
---@param priorityScale number
---@param interfaceMask number
---@param queryMask number
---@return ...
function MOAIPartition:hullListForRay(x, y, z, xdirection, ydirection, zdirection, sortMode, xScale, yScale, zScale, priorityScale, interfaceMask, queryMask) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
---@param sortMode number
---@param xScale number
---@param yScale number
---@param zScale number
---@param priorityScale number
---@param interfaceMask number
---@param queryMask number
---@return ...
function MOAIPartition:hullListForRect(xMin, yMin, xMax, yMax, sortMode, xScale, yScale, zScale, priorityScale, interfaceMask, queryMask) end

---@param hull MOAIPartitionHull
---@return nilRemoves
function MOAIPartition:reserveLevels(hull) end

---@param levelID number
---@param cellSize number
---@param xCells number
---@param yCells number
function MOAIPartition:setLevel(levelID, cellSize, xCells, yCells) end

---@param planeID number
function MOAIPartition:setPlane(planeID) end


---@class MOAIPartitionHull
MOAIPartitionHull = { }

---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
function MOAIPartitionHull:getBounds() end

---@return number
---@return number
---@return number
function MOAIPartitionHull:getDims() end

---@return MOAIPartition
function MOAIPartitionHull:getPartition() end

---@return number
function MOAIPartitionHull:getPriority() end

---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
function MOAIPartitionHull:getWorldBounds() end

---@param x number
---@param y number
---@param z number
---@param pad number
---@return boolean
function MOAIPartitionHull:inside(x, y, z, pad) end

function MOAIPartitionHull:setBounds() end

---@param expandForSort boolean
function MOAIPartitionHull:setExpandForSort(expandForSort) end

---@param granularity int
function MOAIPartitionHull:setHitGranularity(granularity) end

---@param priority number
function MOAIPartitionHull:setPriority(priority) end


---@class MOAIPartitionResultBuffer
MOAIPartitionResultBuffer = { }


---@class MOAIPartitionViewLayer
MOAIPartitionViewLayer = { }

---@param sortMode number
---@param sortInViewSpace boolean
---@param xSortScale number
---@param ySortScale number
---@param zSortScale number
---@param pSortScale number
---@return ...
function MOAIPartitionViewLayer:getPropViewList(sortMode, sortInViewSpace, xSortScale, ySortScale, zSortScale, pSortScale) end

---@return number
function MOAIPartitionViewLayer:getSortMode() end

---@return number
---@return number
---@return number
function MOAIPartitionViewLayer:getSortScale() end

---@param partitionCull2D boolean
function MOAIPartitionViewLayer:setPartitionCull2D(partitionCull2D) end

---@param sortMode number
---@param sortInViewSpace boolean
function MOAIPartitionViewLayer:setSortMode(sortMode, sortInViewSpace) end

---@param x number
---@param y number
---@param z number
---@param priority number
function MOAIPartitionViewLayer:setSortScale(x, y, z, priority) end


---@class MOAIPathFinder
MOAIPathFinder = { }

---@param iterations number
---@return boolean
function MOAIPathFinder:findPath(iterations) end

---@return MOAIPathGraph
function MOAIPathFinder:getGraph() end

---@param index number
---@return number
function MOAIPathFinder:getPathEntry(index) end

---@return number
function MOAIPathFinder:getPathSize() end

---@param startNodeID number
---@param targetNodeID number
function MOAIPathFinder:init(startNodeID, targetNodeID) end

---@param size number
function MOAIPathFinder:reserveTerrainWeights(size) end

---@param heuristic number
function MOAIPathFinder:setFlags(heuristic) end

---@param grid MOAIGrid
function MOAIPathFinder:setGraph(grid) end

---@param heuristic number
function MOAIPathFinder:setHeuristic(heuristic) end

---@param terrainDeck MOAIPathTerrainDeck
function MOAIPathFinder:setTerrainDeck(terrainDeck) end

---@param mask number
function MOAIPathFinder:setTerrainMask(mask) end

---@param index number
---@param deltaScale number
---@param penaltyScale number
function MOAIPathFinder:setTerrainWeight(index, deltaScale, penaltyScale) end

---@param gWeight number
---@param hWeight number
function MOAIPathFinder:setWeight(gWeight, hWeight) end


---@class MOAIPathTerrainDeck
MOAIPathTerrainDeck = { }

---@param idx number
---@return number
function MOAIPathTerrainDeck:getMask(idx) end

---@param idx number
---@return ...
function MOAIPathTerrainDeck:getTerrainVec(idx) end

---@param deckSize number
---@param terrainVecSize number
function MOAIPathTerrainDeck:reserve(deckSize, terrainVecSize) end

---@param idx number
---@param mask number
function MOAIPathTerrainDeck:setMask(idx, mask) end

---@param idx number
---@param values float...
function MOAIPathTerrainDeck:setTerrainVec(idx, values) end


---@class MOAIPinTransform
MOAIPinTransform = { }

---@param sourceTransform MOAITransformBase
---@param sourceLayer MOAIViewLayer
---@param destLayer MOAIViewLayer
function MOAIPinTransform:init(sourceTransform, sourceLayer, destLayer) end


---@class MOAIPointerSensor
MOAIPointerSensor = { }

---@return number
---@return number
function MOAIPointerSensor:getLoc() end

---@param callback function
function MOAIPointerSensor:setCallback(callback) end


---@class MOAIScissorRect
MOAIScissorRect = { }

---@return number
---@return number
---@return number
---@return number
function MOAIScissorRect:getRect() end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
function MOAIScissorRect.setRect(x1, y1, x2, y2) end

---@param parent MOAIScissorRect
function MOAIScissorRect:setScissorRect(parent) end


---@class MOAIScriptNode
MOAIScriptNode = { }

---@param nAttributes number
function MOAIScriptNode:reserveAttrs(nAttributes) end

---@param onUpdate function
function MOAIScriptNode:setCallback(onUpdate) end


---@class MOAISensor
MOAISensor = { }


---@class MOAISerializer
MOAISerializer = { }

---@param filename string
---@param data table
function MOAISerializer.serializeToFile(filename, data) end

---@param data table
---@return string
function MOAISerializer.serializeToString(data) end


---@class MOAIShader
MOAIShader = { }


---@class MOAIShaderMgr
MOAIShaderMgr = { }

---@param shaderID number
function MOAIShaderMgr.getProgram(shaderID) end


---@class MOAIShaderProgram
MOAIShaderProgram = { }

---@param idx number
---@param name string
---@param type number
---@param width number
---@param count number
function MOAIShaderProgram:declareUniform(idx, name, type, width, count) end

---@param vertexShaderSource string
---@param fragmentShaderSource string
function MOAIShaderProgram:load(vertexShaderSource, fragmentShaderSource) end

---@param nUniforms number
function MOAIShaderProgram:reserveUniforms(nUniforms) end

---@param index number
---@param name string
function MOAIShaderProgram:setVertexAttribute(index, name) end


---@class MOAISim
MOAISim = { }

---@param mask number
function MOAISim.clearLoopFlags(mask) end

function MOAISim.clearRenderStack() end

function MOAISim.crash() end

function MOAISim.enterFullscreenMode() end

function MOAISim.exitFullscreenMode() end

---@param frames number
---@return number
function MOAISim.framesToTime(frames) end

---@return MOAIActionTree
function MOAISim.getActionMgr() end

---@return number
function MOAISim.getDeviceTime() end

---@return number
function MOAISim.getElapsedTime() end

---@return number
function MOAISim.getLoopFlags() end

---@return number
function MOAISim.getLuaObjectCount() end

---@return table
function MOAISim.getMemoryUsage() end

---@return number
---@return number
function MOAISim.getMemoryUsagePlain() end

---@return number
---@return number
---@return number
---@return number
---@return number
function MOAISim.getPerformance() end

---@return number
function MOAISim.getStep() end

---@return number
function MOAISim.getStepCount() end

function MOAISim.hideCursor() end

---@param title string
---@param width number
---@param height number
function MOAISim.openWindow(title, width, height) end

---@param pause boolean
function MOAISim.pauseTimer(pause) end

function MOAISim.popRenderPass() end

---@param renderable MOAIDrawable
function MOAISim.pushRenderPass(renderable) end

---@param renderable MOAIDrawable
function MOAISim.removeRenderPass(renderable) end

---@param boostThreshold number
function MOAISim.setBoostThreshold(boostThreshold) end

---@param budget number
function MOAISim.setCpuBudget(budget) end

---@param active boolean
function MOAISim.setGCActive(active) end

---@param step number
function MOAISim.setGCStep(step) end

---@param longDelayThreshold number
function MOAISim.setLongDelayThreshold(longDelayThreshold) end

---@param flags number
function MOAISim.setLoopFlags(flags) end

---@param enable boolean
function MOAISim.setLuaAllocLogEnabled(enable) end

---@param step number
function MOAISim.setStep(step) end

---@param count number
function MOAISim.setStepMultiplier(count) end

---@param count number
function MOAISim.setStepSmoothing(count) end

function MOAISim.setTextInputRect() end

---@param timerError number
function MOAISim.setTimerError(timerError) end

---@param callback function
function MOAISim.setTraceback(callback) end

function MOAISim.showCursor() end

---@param time number
---@return number
function MOAISim.timeToFrames(time) end


---@class MOAISpriteDeck2D
MOAISpriteDeck2D = { }

---@param idx number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
function MOAISpriteDeck2D:getQuad(idx) end

---@param idx number
---@return number
---@return number
---@return number
---@return number
function MOAISpriteDeck2D:getRect(idx) end

---@param idx number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
function MOAISpriteDeck2D:getUVQuad(idx) end

---@param idx number
---@return number
---@return number
---@return number
---@return number
function MOAISpriteDeck2D:getUVRect(idx) end

---@param nQuads number
function MOAISpriteDeck2D:reserveQuads(nQuads) end

---@param nLists number
function MOAISpriteDeck2D:reserveSpriteLists(nLists) end

---@param nPairs number
function MOAISpriteDeck2D:reserveSprites(nPairs) end

---@param nUVQuads number
function MOAISpriteDeck2D:reserveUVQuads(nUVQuads) end

---@param idx number
---@param x0 number
---@param y0 number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
function MOAISpriteDeck2D:setQuad(idx, x0, y0, x1, y1, x2, y2, x3, y3) end

---@param idx number
---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAISpriteDeck2D:setRect(idx, xMin, yMin, xMax, yMax) end

---@param idx number
---@param uvQuadID number
---@param quadID number
---@param materialID number
function MOAISpriteDeck2D:setSprite(idx, uvQuadID, quadID, materialID) end

---@param idx number
---@param basePairID number
---@param totalPairs number
function MOAISpriteDeck2D:setSpriteList(idx, basePairID, totalPairs) end

---@param idx number
---@param x0 number
---@param y0 number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
function MOAISpriteDeck2D:setUVQuad(idx, x0, y0, x1, y1, x2, y2, x3, y3) end

---@param idx number
---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAISpriteDeck2D:setUVRect(idx, xMin, yMin, xMax, yMax) end

---@param transform MOAITransform
function MOAISpriteDeck2D:transform(transform) end

---@param transform MOAITransform
function MOAISpriteDeck2D:transformUV(transform) end


---@class MOAIStaticGlyphCache
MOAIStaticGlyphCache = { }


---@class MOAIStream
MOAIStream = { }

---@param clipBase number
---@param clipSize number
---@param chunkSize number
---@param size number
---@param invert boolean
---@return number
function MOAIStream:collapse(clipBase, clipSize, chunkSize, size, invert) end

---@return number
function MOAIStream:compact() end

function MOAIStream:flush() end

---@return number
function MOAIStream:getCursor() end

---@return number
function MOAIStream:getLength() end

---@param byteCount number
---@return string
---@return number
function MOAIStream:read(byteCount) end

---@return number
---@return number
function MOAIStream:read16() end

---@return number
---@return number
function MOAIStream:read32() end

---@return number
---@return number
function MOAIStream:read8() end

---@return number
---@return number
function MOAIStream:readBoolean() end

---@return number
---@return number
function MOAIStream:readDouble() end

---@return number
---@return number
function MOAIStream:readFloat() end

---@param format string
---@return ...
---@return number
function MOAIStream:readFormat(format) end

---@return number
---@return number
function MOAIStream:readU16() end

---@return number
---@return number
function MOAIStream:readU32() end

---@return number
---@return number
function MOAIStream:readU8() end

---@param offset number
---@param mode number
function MOAIStream:seek(offset, mode) end

---@param bytes string
---@param size number
---@return number
function MOAIStream:write(bytes, size) end

---@param value number
---@return number
function MOAIStream:write16(value) end

---@param value number
---@return number
function MOAIStream:write32(value) end

---@param value number
---@return number
function MOAIStream:write8(value) end

---@param value boolean
---@return number
function MOAIStream:writeBoolean(value) end

---@param r number
---@param g number
---@param b number
---@param a number
function MOAIStream:writeColor32(r, g, b, a) end

---@param value number
---@return number
function MOAIStream:writeDouble(value) end

---@param value number
---@return number
function MOAIStream:writeFloat(value) end

---@param format string
---@param values ...
---@return number
function MOAIStream:writeFormat(format, values) end

---@param stream MOAIStream
---@param size number
---@return number
function MOAIStream:writeStream(stream, size) end

---@param value number
---@return number
function MOAIStream:writeU16(value) end

---@param value number
---@return number
function MOAIStream:writeU32(value) end

---@param value number
---@return number
function MOAIStream:writeU8(value) end


---@class MOAIStreamAdapter
MOAIStreamAdapter = { }

---@param self MOAIStreamWriter
function MOAIStreamAdapter.close(self) end

---@param target MOAIStream
---@return boolean
function MOAIStreamAdapter:openBase64Reader(target) end

---@param target MOAIStream
---@return boolean
function MOAIStreamAdapter:openBase64Writer(target) end

---@param target MOAIStream
---@param windowBits number
---@return boolean
function MOAIStreamAdapter:openDeflateReader(target, windowBits) end

---@param target MOAIStream
---@param level number
---@param windowBits number
---@return boolean
function MOAIStreamAdapter:openDeflateWriter(target, level, windowBits) end

---@param self MOAIStreamReader
---@param target MOAIStream
---@return boolean
function MOAIStreamAdapter.openHex(self, target) end


---@class MOAIStreamReader
MOAIStreamReader = { }


---@class MOAIStreamWriter
MOAIStreamWriter = { }


---@class MOAIStretchPatch2D
MOAIStretchPatch2D = { }

---@param nColumns number
function MOAIStretchPatch2D:reserveColumns(nColumns) end

---@param nRows number
function MOAIStretchPatch2D:reserveRows(nRows) end

---@param nUVRects number
function MOAIStretchPatch2D:reserveUVRects(nUVRects) end

---@param idx number
---@param percent number
---@param canStretch boolean
function MOAIStretchPatch2D:setColumn(idx, percent, canStretch) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAIStretchPatch2D:setRect(xMin, yMin, xMax, yMax) end

---@param idx number
---@param percent number
---@param canStretch boolean
function MOAIStretchPatch2D:setRow(idx, percent, canStretch) end

---@param idx number
---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAIStretchPatch2D:setUVRect(idx, xMin, yMin, xMax, yMax) end


---@class MOAITextBundle
MOAITextBundle = { }

---@param buffer MOAIDataBuffer
---@return number
function MOAITextBundle:load(buffer) end

---@param key string
---@return string
---@return boolean
function MOAITextBundle:lookup(key) end


---@class MOAITextLabel
MOAITextLabel = { }

---@return MOAITextStyle
function MOAITextLabel:affirmStyle() end

function MOAITextLabel:clearHighlights() end

---@return number
---@return number
function MOAITextLabel:getAlignment() end

---@return number
function MOAITextLabel:getGlyphScale() end

---@return number
function MOAITextLabel:getLineSpacing() end

---@return number
---@return number
function MOAITextLabel:getOverrunRules() end

---@return number
---@return number
---@return number
---@return number
function MOAITextLabel:getRect() end

---@return number
---@return number
---@return number
function MOAITextLabel:getSizingRules() end

---@return MOAITextStyle
function MOAITextLabel:getStyle() end

---@return string
function MOAITextLabel:getText() end

---@param index number
---@param size number
---@return number
---@return number
---@return number
---@return number
function MOAITextLabel:getTextBounds(index, size) end

---@return boolean
function MOAITextLabel:more() end

---@param reveal boolean
function MOAITextLabel:nextPage(reveal) end

---@param nCurves number
function MOAITextLabel:reserveCurves(nCurves) end

function MOAITextLabel:revealAll() end

---@param hAlignment number
---@param vAlignment number
function MOAITextLabel:setAlignment(hAlignment, vAlignment) end

---@param autoflip boolean
function MOAITextLabel:setAutoFlip(autoflip) end

---@param xMin number
---@param yMin number
---@param zMin number
---@param xMax number
---@param yMax number
---@param zMax number
function MOAITextLabel:setBounds(xMin, yMin, zMin, xMax, yMax, zMax) end

---@param curveID number
---@param curve MOAIAnimCurve
function MOAITextLabel:setCurve(curveID, curve) end

---@param font MOAIFont
function MOAITextLabel:setFont(font) end

---@param glyphScale number
---@return number
function MOAITextLabel:setGlyphScale(glyphScale) end

---@param index number
---@param size number
---@param r number
---@param g number
---@param b number
---@param a number
function MOAITextLabel:setHighlight(index, size, r, g, b, a) end

---@param hLineSnap number
---@param vLineSnap number
function MOAITextLabel:setLineSnap(hLineSnap, vLineSnap) end

---@param lineSpacing number
function MOAITextLabel:setLineSpacing(lineSpacing) end

---@param firstOverrunRule number
---@param overrunRule number
function MOAITextLabel:setOverrunRules(firstOverrunRule, overrunRule) end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
function MOAITextLabel:setRect(x1, y1, x2, y2) end

---@param limitWidth boolean
---@param limitHeight boolean
function MOAITextLabel:setRectLimits(limitWidth, limitHeight) end

---@param reveal number
function MOAITextLabel:setReveal(reveal) end

---@param hLayoutSizingRule number
---@param vLayoutSizingRule number
---@param lineSizingRule number
function MOAITextLabel:setSizingRules(hLayoutSizingRule, vLayoutSizingRule, lineSizingRule) end

---@param speed number
function MOAITextLabel:setSpeed(speed) end

---@param defaultStyle MOAITextStyle
function MOAITextLabel:setStyle(defaultStyle) end

---@param newStr string
function MOAITextLabel:setText(newStr) end

---@param points number
---@param dpi number
function MOAITextLabel:setTextSize(points, dpi) end

---@param rule number
function MOAITextLabel:setWordBreak(rule) end

---@param yFlip boolean
function MOAITextLabel:setYFlip(yFlip) end

---@return MOAIAction
function MOAITextLabel:spool() end


---@class MOAITextStyle
MOAITextStyle = { }

---@return number
---@return number
---@return number
---@return number
function MOAITextStyle:getColor() end

---@return MOAIFont
function MOAITextStyle:getFont() end

---@return number
function MOAITextStyle:getScale() end

---@return number
function MOAITextStyle:getSize() end

---@param r number
---@param g number
---@param b number
---@param a number
function MOAITextStyle:setColor(r, g, b, a) end

---@param font MOAIFont
function MOAITextStyle:setFont(font) end

---@param hPad number
---@param vPad number
function MOAITextStyle:setPadding(hPad, vPad) end

---@param scale number
function MOAITextStyle:setScale(scale) end

---@param shader variant
---@return MOAIShader
function MOAITextStyle:setShader(shader) end

---@param points number
---@param dpi number
function MOAITextStyle:setSize(points, dpi) end


---@class MOAITexture
MOAITexture = { }

---@param filename string
---@param transform number
---@param debugname string
function MOAITexture:load(filename, transform, debugname) end


---@class MOAITextureBase
MOAITextureBase = { }

---@return number
---@return number
function MOAITextureBase:getSize() end

function MOAITextureBase:release() end

---@param debugName string
function MOAITextureBase:setDebugName(debugName) end

---@param min number
---@param mag number
function MOAITextureBase:setFilter(min, mag) end

---@param wrap boolean
function MOAITextureBase:setWrap(wrap) end


---@class MOAITileDeck2D
MOAITileDeck2D = { }

---@param x0 number
---@param y0 number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
function MOAITileDeck2D:setQuad(x0, y0, x1, y1, x2, y2, x3, y3) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAITileDeck2D:setRect(xMin, yMin, xMax, yMax) end

---@param width number
---@param height number
---@param cellWidth number
---@param cellHeight number
---@param xOff number
---@param yOff number
---@param tileWidth number
---@param tileHeight number
function MOAITileDeck2D:setSize(width, height, cellWidth, cellHeight, xOff, yOff, tileWidth, tileHeight) end

---@param x0 number
---@param y0 number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
function MOAITileDeck2D:setUVQuad(x0, y0, x1, y1, x2, y2, x3, y3) end

---@param xMin number
---@param yMin number
---@param xMax number
---@param yMax number
function MOAITileDeck2D:setUVRect(xMin, yMin, xMax, yMax) end

---@param transform MOAITransform
function MOAITileDeck2D:transform(transform) end

---@param transform MOAITransform
function MOAITileDeck2D:transformUV(transform) end


---@class MOAITimer
MOAITimer = { }

---@return number
function MOAITimer:getSpeed() end

---@return number
function MOAITimer:getTime() end

---@return number
function MOAITimer:getTimesExecuted() end

---@param curve MOAIAnimCurve
function MOAITimer:setCurve(curve) end

---@param mode number
function MOAITimer:setMode(mode) end

---@param endTime number
function MOAITimer:setSpan(endTime) end

---@param speed number
function MOAITimer:setSpeed(speed) end

---@param time number
function MOAITimer:setTime(time) end

function MOAITimer:toggleDirection() end


---@class MOAITouchSensor
MOAITouchSensor = { }

---@return number
function MOAITouchSensor:countTouches() end

---@param idx number
---@return boolean
function MOAITouchSensor:down(idx) end

---@return number
---@return ...
---@return number
function MOAITouchSensor:getActiveTouches() end

---@return number
---@return number
function MOAITouchSensor:getCenterLoc() end

---@param id number
---@return number
---@return number
---@return number
function MOAITouchSensor:getTouch(id) end

---@return boolean
function MOAITouchSensor:hasTouches() end

---@param idx number
---@return boolean
function MOAITouchSensor:isDown(idx) end

---@param accept boolean
function MOAITouchSensor:setAcceptCancel(accept) end

---@param callback function
function MOAITouchSensor:setCallback(callback) end

---@param margin number
function MOAITouchSensor:setTapMargin(margin) end

---@param time number
function MOAITouchSensor:setTapTime(time) end

---@param idx number
---@return boolean
function MOAITouchSensor:up(idx) end


---@class MOAITrace
MOAITrace = { }


---@class MOAITransform
MOAITransform = { }

---@param xDelta number
---@param yDelta number
---@param zDelta number
function MOAITransform:addLoc(xDelta, yDelta, zDelta) end

---@param xDelta number
---@param yDelta number
---@param zDelta number
function MOAITransform:addPiv(xDelta, yDelta, zDelta) end

---@param xDelta number
---@param yDelta number
---@param zDelta number
function MOAITransform:addRot(xDelta, yDelta, zDelta) end

---@param xSclDelta number
---@param ySclDelta number
---@param zSclDelta number
function MOAITransform:addScl(xSclDelta, ySclDelta, zSclDelta) end

---@return number
---@return number
---@return number
function MOAITransform:getLoc() end

---@return number
---@return number
---@return number
function MOAITransform:getPiv() end

---@return number
---@return number
---@return number
function MOAITransform:getRot() end

---@return number
---@return number
---@return number
function MOAITransform:getScl() end

---@param xDelta number
---@param yDelta number
---@param zDelta number
---@param xRotDelta number
---@param yRotDelta number
---@param zRotDelta number
---@param xSclDelta number
---@param ySclDelta number
---@param zSclDelta number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAITransform:move(xDelta, yDelta, zDelta, xRotDelta, yRotDelta, zRotDelta, xSclDelta, ySclDelta, zSclDelta, length, mode) end

---@param xDelta number
---@param yDelta number
---@param zDelta number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAITransform:moveLoc(xDelta, yDelta, zDelta, length, mode) end

---@param xDelta number
---@param yDelta number
---@param zDelta number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAITransform:movePiv(xDelta, yDelta, zDelta, length, mode) end

---@param xDelta number
---@param yDelta number
---@param zDelta number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAITransform:moveRot(xDelta, yDelta, zDelta, length, mode) end

---@param xSclDelta number
---@param ySclDelta number
---@param zSclDelta number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAITransform:moveScl(xSclDelta, ySclDelta, zSclDelta, length, mode) end

---@param xGoal number
---@param yGoal number
---@param zGoal number
---@param xRotGoal number
---@param yRotGoal number
---@param zRotGoal number
---@param xSclGoal number
---@param ySclGoal number
---@param zSclGoal number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAITransform:seek(xGoal, yGoal, zGoal, xRotGoal, yRotGoal, zRotGoal, xSclGoal, ySclGoal, zSclGoal, length, mode) end

---@param xGoal number
---@param yGoal number
---@param zGoal number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAITransform:seekLoc(xGoal, yGoal, zGoal, length, mode) end

---@param xGoal number
---@param yGoal number
---@param zGoal number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAITransform:seekPiv(xGoal, yGoal, zGoal, length, mode) end

---@param xRotGoal number
---@param yRotGoal number
---@param zRotGoal number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAITransform:seekRot(xRotGoal, yRotGoal, zRotGoal, length, mode) end

---@param xSclGoal number
---@param ySclGoal number
---@param zSclGoal number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAITransform:seekScl(xSclGoal, ySclGoal, zSclGoal, length, mode) end

---@param x number
---@param y number
---@param z number
function MOAITransform:setLoc(x, y, z) end

---@param xPiv number
---@param yPiv number
---@param zPiv number
function MOAITransform:setPiv(xPiv, yPiv, zPiv) end

---@param xRot number
---@param yRot number
---@param zRot number
function MOAITransform:setRot(xRot, yRot, zRot) end

---@param xScl number
---@param yScl number
---@param zScl number
function MOAITransform:setScl(xScl, yScl, zScl) end

---@param yx number
---@param zx number
function MOAITransform:setShearByX(yx, zx) end

---@param xy number
---@param zy number
function MOAITransform:setShearByY(xy, zy) end

---@param xz number
---@param yz number
function MOAITransform:setShearByZ(xz, yz) end


---@class MOAITransformBase
MOAITransformBase = { }

---@return number
---@return number
---@return number
function MOAITransformBase:getWorldDir() end

---@return number
---@return number
---@return number
function MOAITransformBase:getWorldLoc() end

---@return number
function MOAITransformBase:getWorldRot() end

---@return number
---@return number
---@return number
function MOAITransformBase:getWorldScl() end

---@param self MOAITransform
---@return number
---@return number
---@return number
function MOAITransformBase.getWorldXAxis(self) end

---@param self MOAITransform
---@param length number
---@return number
---@return number
---@return number
function MOAITransformBase.getWorldXNormal(self, length) end

---@param self MOAITransform
---@return number
---@return number
---@return number
function MOAITransformBase.getWorldYAxis(self) end

---@param self MOAITransform
---@param length number
---@return number
---@return number
---@return number
function MOAITransformBase.getWorldYNormal(self, length) end

---@param self MOAITransform
---@return number
---@return number
---@return number
function MOAITransformBase.getWorldZAxis(self) end

---@param self MOAITransform
---@param length number
---@return number
---@return number
---@return number
function MOAITransformBase.getWorldZNormal(self, length) end

---@param self MOAITransform
---@param x number
---@param y number
---@param z number
---@param w number
---@return number
---@return number
---@return number
---@return number
function MOAITransformBase.modelToWorld(self, x, y, z, w) end

---@param parent MOAINode
function MOAITransformBase:setParent(parent) end

---@param self MOAITransform
---@param x number
---@param y number
---@param z number
---@param w number
---@return number
---@return number
---@return number
---@return number
function MOAITransformBase.worldToModel(self, x, y, z, w) end


---@class MOAIUntzSampleBuffer
MOAIUntzSampleBuffer = { }

---@return table
function MOAIUntzSampleBuffer:getData() end

---@return number
---@return number
---@return number
---@return number
---@return number
function MOAIUntzSampleBuffer:getInfo() end

---@param filename string
function MOAIUntzSampleBuffer:load(filename) end

---@param channels number
---@param frames number
---@param sampleRate number
function MOAIUntzSampleBuffer:prepareBuffer(channels, frames, sampleRate) end

---@param data table
---@param startIndex number
function MOAIUntzSampleBuffer:setData(data, startIndex) end

---@param raw string
---@param of number
---@param index number
function MOAIUntzSampleBuffer:setRawData(raw, of, index) end


---@class MOAIUntzSound
MOAIUntzSound = { }

---@return string
function MOAIUntzSound:getFilename() end

---@return number
function MOAIUntzSound:getLength() end

---@return number
function MOAIUntzSound:getPosition() end

---@return number
function MOAIUntzSound:getVolume() end

---@return boolean
function MOAIUntzSound:isLooping() end

---@return boolean
function MOAIUntzSound:isPaused() end

---@return boolean
function MOAIUntzSound:isPlaying() end

---@param filename string
function MOAIUntzSound:load(filename) end

---@param self MOAITransform
---@param vDelta number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAIUntzSound.moveVolume(self, vDelta, length, mode) end

function MOAIUntzSound:pause() end

function MOAIUntzSound:play() end

---@param self MOAITransform
---@param vGoal number
---@param length number
---@param mode number
---@return MOAIEaseDriver
function MOAIUntzSound.seekVolume(self, vGoal, length, mode) end

---@param looping boolean
function MOAIUntzSound:setLooping(looping) end

---@param startTime double
---@param endTime double
function MOAIUntzSound:setLoopPoints(startTime, endTime) end

---@param position boolean
function MOAIUntzSound:setPosition(position) end

---@param volume boolean
function MOAIUntzSound:setVolume(volume) end

function MOAIUntzSound:stop() end


---@class MOAIUntzSystem
MOAIUntzSystem = { }

---@return number
function MOAIUntzSystem.getSampleRate() end

---@return number
function MOAIUntzSystem.getVolume() end

---@param sampleRate number
---@param numFrames number
function MOAIUntzSystem.initialize(sampleRate, numFrames) end

---@param sampleRate number
function MOAIUntzSystem.setSampleRate(sampleRate) end

---@param volume number
function MOAIUntzSystem.setVolume(volume) end


---@class MOAIVectorSensor
MOAIVectorSensor = { }

---@return number
---@return number
---@return number
function MOAIVectorSensor:getVector() end

---@param self MOAIMotionSensor
---@param callback function
function MOAIVectorSensor.setCallback(self, callback) end


---@class MOAIVectorTesselator
MOAIVectorTesselator = { }


---@class MOAIVertexBuffer
MOAIVertexBuffer = { }

---@param format MOAIVertexFormat
---@return xMin
---@return yMin
---@return zMin
---@return xMax
---@return yMax
---@return zMax
function MOAIVertexBuffer:computeBounds(format) end

---@param vertexSize number
---@return number
function MOAIVertexBuffer:countElements(vertexSize) end

---@param format MOAIVertexFormat
function MOAIVertexBuffer:printVertices(format) end


---@class MOAIVertexFormat
MOAIVertexFormat = { }

---@param index number
---@param type number
---@param size number
---@param normalized boolean
---@param use number
function MOAIVertexFormat:declareAttribute(index, type, size, normalized, use) end

---@param index number
---@param type number
function MOAIVertexFormat:declareColor(index, type) end

---@param index number
---@param type number
---@param size number
function MOAIVertexFormat:declareCoord(index, type, size) end

---@param index number
---@param type number
function MOAIVertexFormat:declareNormal(index, type) end

---@param index number
---@param type number
---@param size number
function MOAIVertexFormat:declareUV(index, type, size) end

---@return number
function MOAIVertexFormat:getVertexSize() end


---@class MOAIViewport
MOAIViewport = { }

---@param xOff number
---@param yOff number
function MOAIViewport:setOffset(xOff, yOff) end

---@param rotation number
function MOAIViewport:setRotation(rotation) end

---@param xScale number
---@param yScale number
function MOAIViewport:setScale(xScale, yScale) end

---@param width number
---@param height number
function MOAIViewport:setSize(width, height) end


---@class MOAIWheelSensor
MOAIWheelSensor = { }

---@return number
function MOAIWheelSensor:getDelta() end

---@return number
function MOAIWheelSensor:getValue() end

---@param callback function
function MOAIWheelSensor:setCallback(callback) end


---@class ZLContextClass
ZLContextClass = { }


